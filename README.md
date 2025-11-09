# Useful zsh aliases

* Run home-manager switch with `hms`
* Switch into one of the `/devshells` with `nd <devshell name>` e.g. `nd node22`

# Installation

## Initial steps

Clone into `$HOME/.system-nix` using jujutsu (git works too)

If cloning to a different directory, update config.nixConfigDir in the home manager config for the host to ensure home manager config can find the out-of-store config files.

## WSL2

Easiest way to activate on home-manager:

```zsh
nix-shell -p home-manager --run "home-manager switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake .#cwilliams@cwilliams-personal-wsl2"
```

After that, it should be possible to run the alias from anywhere

```zsh
hms
```

# (not ready) Building an ISO

This hasn't been isn't ready as of writing, but this in theory should be how to build an ISO:

```zsh
nix run github:nix-community/nixos-generators -- --flake .#<hostname> --format install-iso 
```
