#!/usr/bin/env zsh

USER_NAME="${USER:-$(id -un 2>/dev/null || echo cwilliams)}"
HOME_DIR="${HOME:-/Users/$USER_NAME}"

export USER="$USER_NAME"
export HOME="$HOME_DIR"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export PLUGIN_DIR="$CONFIG_DIR/plugins"
export SKETCHYBAR_BIN="${SKETCHYBAR_BIN:-$(command -v sketchybar)}"

"$SKETCHYBAR_BIN" --bar display=all position=top height=40 blur_radius=30 color=0x40000000

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
"$SKETCHYBAR_BIN" --default "${default[@]}"

"$PLUGIN_DIR/omniwm.sh" stop
"$SKETCHYBAR_BIN" --remove '/space\..*/' >/dev/null 2>&1 || true
"$SKETCHYBAR_BIN" --remove '/window\..*/' >/dev/null 2>&1 || true
"$PLUGIN_DIR/omniwm.sh" refresh
"$PLUGIN_DIR/omniwm.sh" watch >/dev/null 2>&1 &

"$SKETCHYBAR_BIN" --update
