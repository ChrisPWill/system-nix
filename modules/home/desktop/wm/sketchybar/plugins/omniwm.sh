#!/usr/bin/env bash

set -euo pipefail

USER_NAME="${USER:-$(id -un 2>/dev/null || echo cwilliams)}"
HOME_DIR="${HOME:-/Users/$USER_NAME}"

export USER="$USER_NAME"
export HOME="$HOME_DIR"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"
export CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"

SKETCHYBAR_BIN="${SKETCHYBAR_BIN:-sketchybar}"
STATE_DIR="${TMPDIR:-/tmp}/sketchybar-omniwm"
WORKSPACE_STATE="$STATE_DIR/workspace-items"
WATCH_PID_FILE="$STATE_DIR/watch.pid"
REFRESH_LOCK_DIR="$STATE_DIR/refresh.lock"
LOG_FILE="${SKETCHYBAR_OMNIWM_LOG:-$STATE_DIR/omniwm.log}"

mkdir -p "$STATE_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

run_sketchybar() {
  if ! "$SKETCHYBAR_BIN" "$@" >>"$LOG_FILE" 2>&1; then
    log "sketchybar failed: $*"
  fi
}

safe_name() {
  printf '%s' "$1" | LC_CTYPE=C tr -c 'A-Za-z0-9_.-' '_'
}

shell_quote() {
  local value="${1//\'/\'\\\'\'}"
  printf "'%s'" "$value"
}

app_icon() {
  local source="$1"
  local icon

  icon="$(printf '%s' "$source" | cut -c1 | tr '[:lower:]' '[:upper:]')"
  if [[ -z $icon ]]; then
    printf '?'
  else
    printf '%s' "$icon"
  fi
}

query_omni() {
  local kind="$1"

  omniwmctl query "$kind" --format json | jq -e -c --arg kind "$kind" '
    if .ok == true then
      .result.payload[$kind] // []
    else
      error(.message // "omniwmctl query failed")
    end
  '
}

workspace_rows() {
  jq -r '
    def str($value): if $value == null then "" else ($value | tostring) end;

    .[]
    | [
        str(.number // .rawName // .displayName // .id),
        str(.displayName // .rawName // .number),
        str(.rawName // .number // .displayName // .id),
        str(.isFocused // false),
        str(.isCurrent // false),
        str(.isVisible // false),
        str(.counts.total // 0)
      ]
    | @tsv
  '
}

focused_window_row() {
  jq -r '
    def str($value): if $value == null then "" else ($value | tostring) end;

    ([.[] | select(.isFocused == true)][0] // {})
    | if (.id // "") == "" then
        empty
      else
        [
          str(.id),
          str(.app.name),
          str(.title // .app.name)
        ]
        | @tsv
      end
  '
}

set_workspace_item() {
  local item="$1"
  local label="$2"
  local command_name="$3"
  local active="$4"
  local total="$5"
  local background_color="0x44ffffff"
  local border_width="0"
  local shadow="off"
  local count_label=""

  if [[ $active == "true" ]]; then
    background_color="0xff003547"
    border_width="2"
    shadow="on"
  fi

  if [[ $total != "0" ]]; then
    count_label="$total"
  fi

  run_sketchybar --add item "$item" left
  run_sketchybar --set "$item" \
    drawing=on \
    background.color="$background_color" \
    background.corner_radius=7 \
    background.drawing=on \
    background.border_color=0xAAFFFFFF \
    background.border_width="$border_width" \
    background.height=25 \
    icon="$label" \
    icon.padding_left=10 \
    icon.shadow.drawing="$shadow" \
    icon.shadow.distance=4 \
    icon.shadow.color=0xA0000000 \
    label="$count_label" \
    label.padding_right=5 \
    label.padding_left=0 \
    label.y_offset=-1 \
    label.shadow.drawing="$shadow" \
    label.shadow.color=0xA0000000 \
    label.shadow.distance=4 \
    click_script="omniwmctl workspace focus-name $(shell_quote "$command_name")" \
    script="$PLUGIN_DIR/omniwm.sh refresh"
}

remove_stale_workspaces() {
  local current_file="$1"
  local old_item

  if [[ ! -f $WORKSPACE_STATE ]]; then
    return
  fi

  while IFS= read -r old_item; do
    if [[ -n $old_item ]] && ! grep -qxF "$old_item" "$current_file"; then
      run_sketchybar --remove "$old_item"
    fi
  done <"$WORKSPACE_STATE"
}

refresh_workspaces() {
  local workspaces_json="$1"
  local current_file="$STATE_DIR/workspace-items.current"
  local key label command_name is_focused is_current is_visible total
  local item active

  : >"$current_file"

  while IFS=$'\t' read -r key label command_name is_focused is_current is_visible total; do
    if [[ -z $key || -z $label || -z $command_name ]]; then
      continue
    fi

    item="space.$(safe_name "$key")"
    active="false"

    if [[ $is_focused == "true" || $is_current == "true" || $is_visible == "true" ]]; then
      active="true"
    fi

    printf '%s\n' "$item" >>"$current_file"
    set_workspace_item "$item" "$label" "$command_name" "$active" "$total"
  done < <(printf '%s\n' "$workspaces_json" | workspace_rows)

  remove_stale_workspaces "$current_file"
  mv "$current_file" "$WORKSPACE_STATE"
}

refresh_focused_window() {
  local windows_json="$1"
  local window_id app_name title
  local icon label click_script

  if ! IFS=$'\t' read -r window_id app_name title < <(printf '%s\n' "$windows_json" | focused_window_row); then
    run_sketchybar --set window.focused drawing=off
    return
  fi

  if [[ -z $window_id ]]; then
    run_sketchybar --set window.focused drawing=off
    return
  fi

  icon="$(app_icon "$app_name")"
  label="$title"
  click_script="omniwmctl window focus $(shell_quote "$window_id")"

  if [[ -z $label ]]; then
    label="$app_name"
  fi

  run_sketchybar --add item window.focused left
  run_sketchybar --set window.focused \
    drawing=on \
    background.color=0x44003547 \
    background.corner_radius=7 \
    background.drawing=on \
    background.border_color=0xAAFFFFFF \
    background.border_width=0 \
    background.height=25 \
    icon="$icon" \
    icon.padding_left=10 \
    icon.shadow.drawing=off \
    icon.shadow.distance=4 \
    icon.shadow.color=0xA0000000 \
    label="$label" \
    label.max_chars=80 \
    label.padding_left=10 \
    label.padding_right=8 \
    label.y_offset=-1 \
    label.shadow.drawing=off \
    label.shadow.color=0xA0000000 \
    label.shadow.distance=4 \
    click_script="$click_script"
}

refresh() {
  (
    local workspaces_json windows_json

    if ! mkdir "$REFRESH_LOCK_DIR" 2>/dev/null; then
      exit 0
    fi
    trap 'rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true' EXIT

    if ! command -v omniwmctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
      log "omniwmctl or jq is missing from PATH=$PATH"
      run_sketchybar --set window.focused drawing=off
      exit 0
    fi

    if ! workspaces_json="$(query_omni workspaces 2>&1)"; then
      log "omniwmctl workspaces query failed: $workspaces_json"
      run_sketchybar --set window.focused drawing=off
      exit 0
    fi

    if ! windows_json="$(query_omni windows 2>&1)"; then
      log "omniwmctl windows query failed: $windows_json"
      windows_json="[]"
    fi

    refresh_workspaces "$workspaces_json"
    refresh_focused_window "$windows_json"
  )
}

stop_existing_watch() {
  local pid command

  if [[ ! -f $WATCH_PID_FILE ]]; then
    return
  fi

  pid="$(cat "$WATCH_PID_FILE" 2>/dev/null || true)"
  if [[ -z $pid ]] || ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$WATCH_PID_FILE"
    return
  fi

  command="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  if [[ $command == *"omniwm.sh watch"* || $command == *"omniwmctl watch"* ]]; then
    kill "$pid" 2>/dev/null || true
  fi

  rm -f "$WATCH_PID_FILE"
}

watch() {
  local poll_interval="${SKETCHYBAR_OMNIWM_POLL_INTERVAL:-1}"
  local watch_pid=""

  stop_existing_watch
  printf '%s\n' "$$" >"$WATCH_PID_FILE"
  log "starting watch loop with sketchybar=$SKETCHYBAR_BIN"

  cleanup() {
    if [[ -n $watch_pid ]]; then
      kill "$watch_pid" 2>/dev/null || true
    fi
    rm -f "$WATCH_PID_FILE"
  }
  trap cleanup EXIT INT TERM

  refresh

  if command -v omniwmctl >/dev/null 2>&1 && omniwmctl query subscriptions --format json >/dev/null 2>&1; then
    omniwmctl watch --all --exec "$0" refresh &
    watch_pid="$!"
    wait "$watch_pid" || true
    watch_pid=""
  fi

  while true; do
    sleep "$poll_interval"
    refresh
  done
}

case "${1:-refresh}" in
refresh)
  refresh
  ;;
watch)
  watch
  ;;
stop)
  stop_existing_watch
  ;;
*)
  printf 'usage: %s [refresh|watch|stop]\n' "$0" >&2
  exit 64
  ;;
esac
