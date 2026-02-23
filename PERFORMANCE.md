# To profile performance, try this:

```zsh
nix run github:crabdancing/nix-flamegraph -- -t ".#nixosConfigurations.cwilliams-laptop.config.system.build.toplevel.outPath" -o eval-flamegraph.svg
```

Or try evaluating just home-manager:
```zsh
nix eval .#nixosConfigurations.cwilliams-laptop.config.home-manager.users.cwilliams.home.activationPackage.outPath --eval-profiler flamegraph
```

Then open it in the browser.

# Performance stats

```zsh
NIX_SHOW_STATS_PATH=stats.json nix eval .#nixosConfigurations.cwilliams-laptop.config.system.build.toplevel --option eval-cache false
```

Go to https://notashelf.github.io/nix-evaluator-stats/ and open the file to review

