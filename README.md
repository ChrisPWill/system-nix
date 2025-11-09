# WSL2

Easiest way to activate on home-manager:

```zsh
home-manager switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake ".#cwilliams@cwilliams-personal-wsl2" --show-trace
```