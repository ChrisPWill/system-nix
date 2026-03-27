# Shell Configuration Module

This directory contains the configuration for various shells and shared shell-related tools.

## Structure

- `shared.nix`: Common aliases, prompt (Starship), and shared shell utilities (zoxide, atuin, etc.) that apply across all installed shells.
- `zsh.nix`: Zsh-specific configuration, plugins, and init scripts.
- `fish.nix`: Fish-specific configuration, abbreviations, and interactive init logic.
- `nushell.nix`: Nushell-specific configuration, environment variables, and plugins.

## Philosophy

We aim to keep shell configuration as modular as possible. Common aliases and tools are defined in `shared.nix`, while shell-specific features (like Zsh widgets or Fish abbreviations) remain in their respective files.
