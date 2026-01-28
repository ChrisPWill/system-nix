#!/usr/bin/env zsh

PLUGIN_DIR="$CONFIG_DIR/plugins"

sketchybar --bar display=all position=top height=40 blur_radius=30 color=0x40000000

default=(
  padding_left=5
  padding_right=5
  icon.font="FantasqueSansM Nerd Font Mono:Bold:17.0"
  label.font="FantasqueSansM Nerd Font Mono:Bold:14.0"
  icon.color=0xffffffff
  label.color=0xffffffff
  icon.padding_left=4
  icon.padding_right=4
  label.padding_left=4
  label.padding_right=4
)
sketchybar --default "${default[@]}"

# Add the aerospace_workspace_change event we specified in aerospace.toml
sketchybar --add event aerospace_workspace_change

# Add workspaces for all monitors
for monitor in $(aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}"); do
  for sid in $(aerospace list-workspaces --monitor "$monitor"); do
    # Determine which display this workspace should be shown on
    sketchybar --add item space.$sid left \
      --set space.$sid display="$monitor" \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
      drawing=on \
      background.color=0x44ffffff \
      background.corner_radius=7 \
      background.drawing=on \
      background.border_color=0xAAFFFFFF \
      background.border_width=0 \
      background.height=25 \
      icon="$sid" \
      icon.padding_left=10 \
      icon.shadow.distance=4 \
      icon.shadow.color=0xA0000000 \
      label.padding_right=5 \
      label.padding_left=0 \
      label.y_offset=-1 \
      label.shadow.drawing=off \
      label.shadow.color=0xA0000000 \
      label.shadow.distance=4 \
      click_script="aerospace workspace $sid" \
      script="$PLUGIN_DIR/aerospace.sh $sid"
  done
done

# Currently works when manually executed in bash but not on sketchybar --reload
# TODO: Need to debug this
for monitor in $(aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}"); do
  ACTIVE_WORKSPACE="$(aerospace list-workspaces --monitor "$monitor" --visible)"
  WINDOWS=$(nu -c 'aerospace list-windows --workspace '"$ACTIVE_WORKSPACE"' --json | from json | insert focused {|row| $row.window-id == (aerospace list-windows --focused --json | from json | get 0.window-id) } | insert symbol {|row| $row.app-name | str substring 0..0 | str upcase } | each { |e| ($e.window-id | into string) + "¬" + $e.symbol + "¬" + $e.window-title + "¬" + ($e.focused | into string) } | to text')
  while IFS="¬" read -r window_id symbol window_title focused; do
    sketchybar --add item window.$window_id left \
      --set window.$window_id display="$monitor" \
      --subscribe window.$window_id aerospace_workspace_change \
      --set window.$window_id \
      drawing=on \
      background.color=0x44ffffff \
      background.corner_radius=7 \
      background.drawing=on \
      background.border_color=0xAAFFFFFF \
      background.border_width=0 \
      background.height=25 \
      icon="$symbol" \
      label="$( [ "$focused" = "true" ] && echo "$window_title" )" \
      label.color=0xffffffff \
      label.font="FantasqueSansM Nerd Font Mono:Bold:14.0" \
      label.padding_left=10 \
      label.padding_right=5 \
      label.y_offset=-1 \
      label.shadow.drawing=off \
      label.shadow.color=0xA0000000
  done < <(echo "$WINDOWS")
done

sketchybar --update

