# shellcheck shell=bash
set -euo pipefail

usage() {
  echo "Usage: omniwm-config-merge [--dry-run]" >&2
}

dry_run=false
case "${1:-}" in
"") ;;
--dry-run) dry_run=true ;;
*)
  usage
  exit 2
  ;;
esac

config_dir=$(dirname "$OMNIWM_CONFIG_PATH")
backup_dir="$OMNIWM_STATE_DIR/backups"
managed_ids_path="$OMNIWM_STATE_DIR/managed-ids.json"

mkdir -p "$config_dir" "$OMNIWM_STATE_DIR"

policy_json=$(mktemp "$OMNIWM_STATE_DIR/policy.XXXXXX.json")
current_ids_json=$(mktemp "$OMNIWM_STATE_DIR/current-ids.XXXXXX.json")
cleanup_paths=("$policy_json" "$current_ids_json")
cleanup_dirs=()
# shellcheck disable=SC2329 # Invoked indirectly by the EXIT trap.
cleanup() {
  rm -f -- "${cleanup_paths[@]}"
  for cleanup_dir in "${cleanup_dirs[@]}"; do
    rmdir "$cleanup_dir" 2>/dev/null || true
  done
}
trap cleanup EXIT

toml2json "$OMNIWM_POLICY_PATH" >"$policy_json"
jq -e '{appRules: [.appRules[]?.id]}' "$policy_json" >"$current_ids_json"

for _attempt in 1 2 3; do
  work_dir=$(mktemp -d "$config_dir/.omniwm-merge.XXXXXX")
  cleanup_dirs+=("$work_dir")
  snapshot="$work_dir/settings.toml"
  live_json="$work_dir/live.json"
  merged_json="$work_dir/merged.json"
  merged_toml="$work_dir/merged.toml"
  previous_ids_json="$work_dir/previous-ids.json"
  cleanup_paths+=("$snapshot" "$live_json" "$merged_json" "$merged_toml" "$previous_ids_json")

  if [[ -e $OMNIWM_CONFIG_PATH ]]; then
    cp "$OMNIWM_CONFIG_PATH" "$snapshot"
    original_hash=$(sha256sum "$snapshot" | cut -d ' ' -f 1)
  else
    cp "$OMNIWM_SEED_PATH" "$snapshot"
    original_hash=missing
  fi

  if [[ -e $managed_ids_path ]]; then
    jq -e '.appRules | arrays' "$managed_ids_path" >/dev/null
    cp "$managed_ids_path" "$previous_ids_json"
  else
    printf '{"appRules":[]}\n' >"$previous_ids_json"
  fi

  toml2json "$snapshot" >"$live_json"
  jq \
    --slurpfile policy_file "$policy_json" \
    --slurpfile previous_managed_ids_file "$previous_ids_json" \
    -f "$OMNIWM_MERGE_FILTER" \
    "$live_json" >"$merged_json"
  json2toml "$merged_json" >"$merged_toml"

  # Parsing the rendered output again catches conversion failures before the
  # canonical file is touched.
  toml2json "$merged_toml" | jq -e . >/dev/null

  if jq -e --slurpfile expected "$policy_json" '
    . as $merged
    | $expected[0] as $policy
    | ($merged * ($policy | del(.appRules, .hotkeys, .workspaces))) == $merged
  ' "$merged_json" >/dev/null; then
    :
  else
    echo "omniwm-config-merge: merged settings failed policy validation" >&2
    exit 1
  fi

  if [[ $original_hash != missing ]] && jq -S -c . "$live_json" | cmp -s - <(jq -S -c . "$merged_json"); then
    if ! $dry_run; then
      cp "$current_ids_json" "$managed_ids_path"
    fi
    exit 0
  fi

  if $dry_run; then
    diff -u "$snapshot" "$merged_toml" || true
    exit 0
  fi

  if [[ $original_hash == missing ]]; then
    [[ ! -e $OMNIWM_CONFIG_PATH ]] || continue
  else
    [[ -e $OMNIWM_CONFIG_PATH ]] || continue
    current_hash=$(sha256sum "$OMNIWM_CONFIG_PATH" | cut -d ' ' -f 1)
    [[ $current_hash == "$original_hash" ]] || continue
  fi

  mkdir -p "$backup_dir"
  if [[ $original_hash != missing ]]; then
    backup_name="settings-$(date -u +%Y%m%dT%H%M%SZ)-$$.toml"
    cp "$snapshot" "$backup_dir/$backup_name"
  fi

  chmod 0644 "$merged_toml"
  mv "$merged_toml" "$OMNIWM_CONFIG_PATH"

  managed_ids_tmp="$work_dir/managed-ids.json"
  cleanup_paths+=("$managed_ids_tmp")
  cp "$current_ids_json" "$managed_ids_tmp"
  chmod 0644 "$managed_ids_tmp"
  mv "$managed_ids_tmp" "$managed_ids_path"

  if [[ -d $backup_dir ]]; then
    find "$backup_dir" -type f -name 'settings-*.toml' -print |
      sort -r |
      tail -n +6 |
      while IFS= read -r old_backup; do
        rm -f -- "$old_backup"
      done
  fi

  exit 0
done

echo "omniwm-config-merge: settings changed repeatedly while merging; try again" >&2
exit 1
