#!/usr/bin/env -S nu --stdin

let PLUGIN_DIR = $env.CONFIG_DIR + "/plugins"

sketchybar --bar display=all position=top height=40 blur_radius=30 color=0x40000000

let default_arguments = [
  "padding_left=5",
  "padding_right=5",
  "icon.font='FantasqueSansM Nerd Font Mono:Bold:17.0'",
  "label.font='FantasqueSansM Nerd Font Mono:Bold:14.0'",
  "icon.color=0xffffffff",
  "label.color=0xffffffff",
  "icon.padding_left=4",
  "icon.padding_right=4",
  "label.padding_left=4",
  "label.padding_right=4"
]

sketchybar --default ...$default_arguments

sketchybar --add event aerospace_workspace_change

let monitors = aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}" | detect columns --no-headers | rename monitor
$monitors | each { |m|
  let workspaces = aerospace list-workspaces --monitor $m.monitor | detect columns --no-headers | rename workspace
  $workspaces | each { |ws|
    let workspace_id = $ws.workspace
    let ws_arguments = [
      "--add", "item", $"space.($workspace_id)", "left",
      "--set", $"space.($workspace_id)", $"display=($m.monitor)",
      "--subscribe", $"space.($workspace_id)", "aerospace_workspace_change",
      "--set", $"space.($workspace_id)",
      "drawing=on",
      "background.color=0x44ffffff",
      "background.corner_radius=7",
      "background.drawing=on",
      "background.border_color=0xAAFFFFFF",
      "background.border_width=0",
      "background.height=25",
      $"icon=($workspace_id)",
      "icon.padding_left=10",
      "icon.shadow.distance=4",
      "icon.shadow.color=0xA0000000",
      "label.padding_right=5",
      "label.padding_left=0",
      "label.y_offset=-1",
      "label.shadow.drawing=off",
      "label.shadow.color=0xA0000000",
      "label.shadow.distance=4",
      $"click_script='aerospace workspace ($workspace_id)'",
      $"script='($PLUGIN_DIR)/aerospace.sh ($workspace_id)'",
    ]
    sketchybar ...$ws_arguments
  }
}

sketchybar --update
