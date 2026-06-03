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
STATE_DIR="${SKETCHYBAR_OMNIWM_STATE_DIR:-${TMPDIR:-/tmp}/sketchybar-omniwm}"
WORKSPACE_STATE="$STATE_DIR/workspace-items"
WORKSPACE_PROPS_DIR="$STATE_DIR/workspace-props"
WINDOW_STATE="$STATE_DIR/window-item"
WINDOW_PROPS_STATE="$STATE_DIR/window-focused-props"
ORDER_STATE="$STATE_DIR/item-order"
WATCH_PID_FILE="$STATE_DIR/watch.pid"
REFRESH_LOCK_DIR="$STATE_DIR/refresh.lock"
REFRESH_LOCK_PID_FILE="$REFRESH_LOCK_DIR/pid"
PENDING_REFRESH="$STATE_DIR/refresh.pending"
LOG_FILE="${SKETCHYBAR_OMNIWM_LOG:-$STATE_DIR/omniwm.log}"
SKETCHYBAR_ARGS=()
WORKSPACE_ORDER=()
WORKSPACE_STATE_CONTENT=""
WINDOW_STATE_CONTENT=""

mkdir -p "$STATE_DIR" "$WORKSPACE_PROPS_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

run_sketchybar() {
  if ! "$SKETCHYBAR_BIN" "$@" >>"$LOG_FILE" 2>&1; then
    log "sketchybar failed: $*"
  fi
}

queue_sketchybar() {
  SKETCHYBAR_ARGS+=("$@")
}

flush_sketchybar() {
  if [[ ${#SKETCHYBAR_ARGS[@]} -eq 0 ]]; then
    return
  fi

  run_sketchybar "${SKETCHYBAR_ARGS[@]}"
  SKETCHYBAR_ARGS=()
}

line_list_contains() {
  local lines="$1"
  local item="$2"

  [[ $'\n'"$lines"$'\n' == *$'\n'"$item"$'\n'* ]]
}

load_item_state() {
  WORKSPACE_STATE_CONTENT=""
  WINDOW_STATE_CONTENT=""

  if [[ -f $WORKSPACE_STATE ]]; then
    WORKSPACE_STATE_CONTENT="$(<"$WORKSPACE_STATE")"
  fi

  if [[ -f $WINDOW_STATE ]]; then
    WINDOW_STATE_CONTENT="$(<"$WINDOW_STATE")"
  fi
}

state_contains_item() {
  local state_file="$1"
  local item="$2"
  local lines=""

  case "$state_file" in
  "$WORKSPACE_STATE")
    line_list_contains "$WORKSPACE_STATE_CONTENT" "$item"
    ;;
  "$WINDOW_STATE")
    line_list_contains "$WINDOW_STATE_CONTENT" "$item"
    ;;
  *)
    [[ -f $state_file ]] || return 1
    lines="$(<"$state_file")"
    line_list_contains "$lines" "$item"
    ;;
  esac
}

file_first_line_matches() {
  local file="$1"
  local expected="$2"
  local actual=""

  [[ -f $file ]] || return 1
  IFS= read -r actual <"$file" || true
  [[ $actual == "$expected" ]]
}

acquire_refresh_lock() {
  local lock_pid

  if mkdir "$REFRESH_LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" >"$REFRESH_LOCK_PID_FILE"
    return 0
  fi

  lock_pid="$(cat "$REFRESH_LOCK_PID_FILE" 2>/dev/null || true)"
  if [[ -n $lock_pid ]] && kill -0 "$lock_pid" 2>/dev/null; then
    : >"$PENDING_REFRESH"
    return 1
  fi

  rm -f "$REFRESH_LOCK_PID_FILE"
  rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true

  if mkdir "$REFRESH_LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" >"$REFRESH_LOCK_PID_FILE"
    return 0
  fi

  : >"$PENDING_REFRESH"
  return 1
}

release_refresh_lock() {
  rm -f "$REFRESH_LOCK_PID_FILE"
  rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
}

safe_name() {
  local value="$1"

  if [[ $value =~ ^[A-Za-z0-9_.-]+$ ]]; then
    printf '%s' "$value"
  else
    printf '%s' "$value" | LC_CTYPE=C tr -c 'A-Za-z0-9_.-' '_'
  fi
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
    def workspace_number:
      ((.number // (.rawName | tonumber?) // (.displayName | tonumber?) // 9999) | tonumber);

    sort_by(workspace_number)
    | .[]
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

queue_workspace_item() {
  local item="$1"
  local label="$2"
  local command_name="$3"
  local active="$4"
  local total="$5"
  local props_file="$WORKSPACE_PROPS_DIR/$item"
  local existing="false"
  local background_color="0x44ffffff"
  local border_width="0"
  local shadow="off"
  local count_label=""
  local signature

  if [[ $active == "true" ]]; then
    background_color="0xff003547"
    border_width="2"
    shadow="on"
  fi

  if [[ $total != "0" ]]; then
    count_label="$total"
  fi

  signature="$(printf '%s\t%s\t%s\t%s' "$label" "$command_name" "$active" "$count_label")"

  if state_contains_item "$WORKSPACE_STATE" "$item"; then
    existing="true"
  else
    queue_sketchybar --add item "$item" left
  fi

  if [[ $existing == "true" ]] && file_first_line_matches "$props_file" "$signature"; then
    return
  fi

  queue_sketchybar --set "$item" \
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

  printf '%s\n' "$signature" >"$props_file"
}

queue_stale_workspaces() {
  local current_file="$1"
  local current_items
  local old_item

  if [[ ! -f $WORKSPACE_STATE ]]; then
    return
  fi

  current_items="$(<"$current_file")"

  while IFS= read -r old_item; do
    if [[ -n $old_item ]] && ! line_list_contains "$current_items" "$old_item"; then
      queue_sketchybar --remove "$old_item"
      rm -f "$WORKSPACE_PROPS_DIR/$old_item"
    fi
  done <"$WORKSPACE_STATE"
}

refresh_workspaces() {
  local workspaces_json="$1"
  local current_file="$STATE_DIR/workspace-items.$$"
  local key label command_name is_focused is_current is_visible total
  local item active

  : >"$current_file"

  while IFS=$'\t' read -r key label command_name is_focused is_current is_visible total; do
    if [[ -z $key || -z $label || -z $command_name ]]; then
      continue
    fi

    item="space.$(safe_name "$key")"
    WORKSPACE_ORDER+=("$item")
    active="false"

    if [[ $is_focused == "true" || $is_current == "true" || $is_visible == "true" ]]; then
      active="true"
    fi

    printf '%s\n' "$item" >>"$current_file"
    queue_workspace_item "$item" "$label" "$command_name" "$active" "$total"
  done < <(printf '%s\n' "$workspaces_json" | workspace_rows)

  queue_stale_workspaces "$current_file"
  mv "$current_file" "$WORKSPACE_STATE"
  WORKSPACE_STATE_CONTENT="$(<"$WORKSPACE_STATE")"
}

queue_reorder() {
  local ordered_items=("${WORKSPACE_ORDER[@]}")
  local signature

  if state_contains_item "$WINDOW_STATE" "window.focused"; then
    ordered_items+=("window.focused")
  fi

  if [[ ${#ordered_items[@]} -gt 0 ]]; then
    signature="$(printf '%s|' "${ordered_items[@]}")"
    if file_first_line_matches "$ORDER_STATE" "$signature"; then
      return
    fi

    queue_sketchybar --reorder "${ordered_items[@]}"
    printf '%s\n' "$signature" >"$ORDER_STATE"
  fi
}

queue_hide_focused_window() {
  if file_first_line_matches "$WINDOW_PROPS_STATE" "hidden"; then
    return
  fi

  if state_contains_item "$WINDOW_STATE" "window.focused"; then
    queue_sketchybar --set window.focused drawing=off
  fi

  printf 'hidden\n' >"$WINDOW_PROPS_STATE"
}

refresh_focused_window() {
  local windows_json="$1"
  local window_id app_name title
  local existing="false"
  local icon label click_script
  local signature

  if ! IFS=$'\t' read -r window_id app_name title < <(printf '%s\n' "$windows_json" | focused_window_row); then
    queue_hide_focused_window
    return
  fi

  if [[ -z $window_id ]]; then
    queue_hide_focused_window
    return
  fi

  icon="$(app_icon "$app_name")"
  label="$title"
  click_script="omniwmctl window focus $(shell_quote "$window_id")"

  if [[ -z $label ]]; then
    label="$app_name"
  fi

  signature="$(printf '%s\t%s\t%s\t%s' "$window_id" "$app_name" "$icon" "$label")"

  if state_contains_item "$WINDOW_STATE" "window.focused"; then
    existing="true"
  else
    queue_sketchybar --add item window.focused left
    printf '%s\n' "window.focused" >"$WINDOW_STATE"
    WINDOW_STATE_CONTENT="window.focused"
  fi

  if [[ $existing == "true" ]] && file_first_line_matches "$WINDOW_PROPS_STATE" "$signature"; then
    return
  fi

  queue_sketchybar --set window.focused \
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

  printf '%s\n' "$signature" >"$WINDOW_PROPS_STATE"
}

refresh() {
  (
    local workspaces_json windows_json

    if ! acquire_refresh_lock; then
      exit 0
    fi
    trap release_refresh_lock EXIT

    while true; do
      rm -f "$PENDING_REFRESH"
      SKETCHYBAR_ARGS=()
      WORKSPACE_ORDER=()
      load_item_state

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
      queue_reorder
      flush_sketchybar

      if [[ ! -f $PENDING_REFRESH ]]; then
        break
      fi
    done
  )
}

reset_state() {
  rm -f "$WORKSPACE_STATE" "$WINDOW_STATE" "$WINDOW_PROPS_STATE" "$ORDER_STATE" "$PENDING_REFRESH" "$REFRESH_LOCK_PID_FILE" "$STATE_DIR"/workspace-items.*
  rm -rf "$WORKSPACE_PROPS_DIR"
  mkdir -p "$WORKSPACE_PROPS_DIR"
  rmdir "$REFRESH_LOCK_DIR" 2>/dev/null || true
  : >"$LOG_FILE"
}

remove_items() {
  local item
  local args=()

  if [[ -f $WORKSPACE_STATE ]]; then
    while IFS= read -r item; do
      if [[ -n $item ]]; then
        args+=(--remove "$item")
      fi
    done <"$WORKSPACE_STATE"
  else
    for item in {1..15}; do
      args+=(--remove "space.$item")
    done
  fi

  if state_contains_item "$WINDOW_STATE" "window.focused" || [[ ! -f $WINDOW_STATE ]]; then
    args+=(--remove window.focused)
  fi

  if [[ ${#args[@]} -gt 0 ]]; then
    run_sketchybar "${args[@]}"
  fi
}

stop_existing_watch() {
  local allow_pkill="${1:-true}"
  local pid

  pid="$(cat "$WATCH_PID_FILE" 2>/dev/null || true)"
  if [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    sleep 0.05
    if kill -0 "$pid" 2>/dev/null; then
      kill -KILL "$pid" 2>/dev/null || true
    fi
  fi

  if [[ $allow_pkill == "true" ]] && command -v pkill >/dev/null 2>&1; then
    pkill -f "$PLUGIN_DIR/omniwm.sh watch" 2>/dev/null || true
    pkill -f "omniwm.sh watch" 2>/dev/null || true
    pkill -f "omniwmctl watch --all --exec $PLUGIN_DIR/omniwm.sh refresh" 2>/dev/null || true
    pkill -f "omniwmctl watch --all --exec .*omniwm.sh refresh" 2>/dev/null || true
  fi

  rm -f "$WATCH_PID_FILE"
}

watch() {
  local poll_interval="${SKETCHYBAR_OMNIWM_POLL_INTERVAL:-1}"
  local watch_pid=""
  local status

  stop_existing_watch false
  printf '%s\n' "$$" >"$WATCH_PID_FILE"
  log "starting watch loop with sketchybar=$SKETCHYBAR_BIN"

  cleanup() {
    if [[ -n $watch_pid ]]; then
      kill "$watch_pid" 2>/dev/null || true
    fi
    rm -f "$WATCH_PID_FILE"
  }
  trap cleanup EXIT
  trap 'cleanup; exit 0' INT TERM

  refresh

  if command -v omniwmctl >/dev/null 2>&1 && omniwmctl query subscriptions --format json >/dev/null 2>&1; then
    log "starting omniwmctl event watch"
    omniwmctl watch --all --exec "$0" refresh >>"$LOG_FILE" 2>&1 &
    watch_pid="$!"
    if wait "$watch_pid"; then
      log "omniwmctl event watch exited cleanly"
    else
      status="$?"
      log "omniwmctl event watch exited with status=$status"
    fi
    watch_pid=""
  fi

  log "falling back to polling every ${poll_interval}s"
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
reset-state)
  reset_state
  ;;
remove-items)
  remove_items
  ;;
*)
  printf 'usage: %s [refresh|watch|stop|reset-state|remove-items]\n' "$0" >&2
  exit 64
  ;;
esac
