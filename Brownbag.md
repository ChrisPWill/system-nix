# What is Nix?
## It's
1. A package manager
1. A functional language

## What can you do with Nix?
* Create reproducible development environments
    - Without virtual machines

Let's demo! Anyone remember how painful it is to reproduce a latex environment?

```zsh
cd /tmp
nix flake new --template templates#latexmk ./latex-test
cd latex-test
nix build
```

* Try out software without installing it

Yo I herd wtfutil is a cool dashboard, should I try it?

```zsh
nix-shell -p wtfutil --run wtfutil
```

I need gradle and java as a one-off to run a graphql-gateway validation command

```zsh
nix-shell -p gradle jdk24
gradle <command>
```

* Declaratively specify your home directory
    - More on this later

* Declaratively specify an entire Linux OS
[My old nix config](https://github.com/ChrisPWill/system-config/blob/master/hosts/personal-pc-x64linux/configuration.nix)

## The language
- Declarative
- Purely functional
- Lazily evaluated
- Dynamically typed
- It can be a little painful to use at times, but perfect for what it does.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    # Hacky utility that basically says, produce system for each supported system
    # e.g. Linux, MacOS, etc.
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.default = pkgs.writeShellScriptBin "simple-web-server" ''
        DATE="$(${pkgs.ddate}/bin/ddate +'the %e of %B%, %Y')"
        echo "Hello, World! Today is $DATE." > test.txt
        echo "Yo check out our cool site https://localhost:8765/test.txt"
        ${pkgs.simplehttp2server}/bin/simplehttp2server -listen :8765
      '';
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Can add more packages
          simplehttp2server
        ];
      };
    });
}
```

# What does Chris's config look like?

MORE DEMO

Links
* https://numtide.github.io/blueprint/main/
* https://github.com/dfrankland/envoluntary

# Guiding principles

1. Less is more
    - With great power comes great responsibility
    - Nix makes it easy to configure minute details
    - Holding back pays off. I try to mostly stick to defaults.
    - Also useful - blueprint framework.
        - An opinionated directory-based framework that handles a lot of the Nix-y flake structuring for me.
1. Nix is for packages. Don't put dynamic config in the store
    - Different schools of thought here. After a couple years using Nix,
      I fall on the side of pragmatism.
    - `home-manager` provides a great escape hatch - `mkOutOfStoreSymlink`
1. continuation of  - reduce layers
    - By layers I mean, configure tools in their intended language
    - Hybrid approaches can be great
        * `enableZshIntegration` configures a bunch of useful tooling
        * To not lose this, you could add a line in Nix that sources
          an additional script outside of the Nix store.
    - Example in action - wezterm config
    ```nix
    # Most of my config I want to modify on the fly, so I inject something out of the store
    xdg.configFile."wezterm/extraWezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/out-of-store/wezterm.lua";
    programs.wezterm.extraConfig = "local extraConfig = require('extraWezterm'); return extraConfig";
    # Easy to share my color scheme by using Nix-specific config
    programs.wezterm.colorSchemes = {
      chrisTheme = with config.theme; {
        foreground = foreground;
        background = background;
        cursor_bg = foreground;
        cursor_fg = background;
        cursor_border = light.silver;
        split = normal.silver;
        scrollbar_thumb = light.silver;

        ansi = with normal; [
          black
          red
          green
          yellow
          blue
          magenta
          cyan
          silver
        ];

        brights = with light; [
          gray
          red
          green
          yellow
          blue
          magenta
          cyan
          silver
        ];
      };
    };
    ```
