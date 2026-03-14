# Dev Setup

To get this working locally, run (in this directory):

```bash
ags types -u -d .
```

node_modules is gitignored to avoid vendoring deps

## Running

To run in development mode, use this command:

```bash
nix-shell -p watchexec --run "watchexec -r -e scss,tsx ags run modules/home/graphical-nixos/ags/config/index.tsx"
```
