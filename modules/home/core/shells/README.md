# Core Shell Configuration

This directory contains foundational configuration for interactive shells.

## Structure

- `shared.nix`: Common directory/navigation aliases and prompt configuration.
- `zsh.nix`: Zsh enablement, completion, history, vi-mode, and shared vi-mode hook infrastructure.
- `fish.nix`: Fish enablement, default-shell handoff, vi mode, and startup behavior.
- `nushell.nix`: Nushell enablement, default-shell handoff, environment, settings, and plugins.

## Philosophy

Core shell configuration should stay independent of higher-level tools. Tool-specific widgets, keybindings, abbreviations, aliases, and shell functions live in the domain module that owns the tool.

See [CLI Tools & Hotkeys](../../cli/README.md) for a list of global interactive hotkeys (Alt-O, Alt-W, etc.) and modern Unix tools available across all shells.
