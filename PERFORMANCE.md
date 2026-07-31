# Evaluation performance

Run these commands from the repository root.

## NixOS evaluation flamegraph

```zsh
nix run github:crabdancing/nix-flamegraph -- -t ".#nixosConfigurations.cwilliams-laptop.config.system.build.toplevel.outPath" -o eval-flamegraph.svg
```

## Home Manager evaluation profile

Current Nix has a built-in sampling profiler. It writes folded stack data to
`nix.profile`; convert that data to an SVG with `flamegraph.pl`:

```zsh
nix eval .#nixosConfigurations.cwilliams-laptop.config.home-manager.users.cwilliams.home.activationPackage.outPath \
  --eval-profiler flamegraph \
  --eval-profile-file nix.profile \
  --option eval-cache false
nix shell nixpkgs#flamegraph --command flamegraph.pl nix.profile > eval-flamegraph.svg
```

Open `eval-flamegraph.svg` in a browser.

## Evaluation statistics

```zsh
NIX_SHOW_STATS=1 NIX_SHOW_STATS_PATH=stats.json \
  nix eval .#nixosConfigurations.cwilliams-laptop.config.system.build.toplevel \
  --option eval-cache false
```

Open `stats.json` with
[nix-evaluator-stats](https://notashelf.github.io/nix-evaluator-stats/).
