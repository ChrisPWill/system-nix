#!/usr/bin/env -S nu --stdin

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

def main [workspace_id: string] { 
  if $env.FOCUSED_WORKSPACE == $workspace_id {
    sketchybar --set $env.NAME background.color=0xff003547 label.shadow.drawing=on icon.shadow.drawing=on background.border_width=2
  } else {
    sketchybar --set $env.NAME background.color=0x44FFFFFF label.shadow.drawing=off icon.shadow.drawing=off background.border_width=0
  }
}
