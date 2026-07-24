{
  inputs,
  pkgs,
  ...
}: let
  envoluntary = inputs.envoluntary.packages.${pkgs.stdenv.hostPlatform.system}.default;
  shippedConfig = ../modules/home/dev/envoluntary/envoluntary.toml;
in
  pkgs.runCommand "envoluntary-mappings-check" {
    nativeBuildInputs = [
      envoluntary
      pkgs.jq
    ];
  } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    mkdir -p \
      "$HOME/.system-nix/subdir" \
      "$HOME/code/sequence-platform-api/service" \
      "$HOME/code/sequence-web/app" \
      "$XDG_CONFIG_HOME/envoluntary"
    cp ${shippedConfig} "$XDG_CONFIG_HOME/envoluntary/config.toml"

    check_mapping() {
      path="$1"
      expected="$2"
      envoluntary config print-matching-entries "$path" \
        | jq -e --arg expected "$expected" \
          'length == 1 and .[0].flake_reference == $expected' >/dev/null
    }

    check_mapping "$HOME/.system-nix/subdir" '~/.system-nix#system-nix'
    check_mapping "$HOME/code/sequence-platform-api/service" '~/.system-nix#sequence-platform-api'
    check_mapping "$HOME/code/sequence-web/app" '~/.system-nix#sequence-web'

    adjacent_config="$TMPDIR/adjacent.toml"
    touch "$adjacent_config"

    check_adjacent() {
      marker="$1"
      marker_regex="$2"
      shell="$3"
      project="$TMPDIR/projects/$shell"
      mkdir -p "$project/src"
      touch "$project/$marker"
      envoluntary config add-entry '.*' "~/.system-nix#$shell" \
        --pattern-adjacent ".*/$marker_regex" \
        --config-path "$adjacent_config"
      envoluntary config print-matching-entries "$project/src" \
        --config-path "$adjacent_config" \
        | jq -e --arg expected "~/.system-nix#$shell" \
          'map(select(.flake_reference == $expected)) | length == 1' >/dev/null
    }

    check_adjacent 'Cargo.toml' 'Cargo\.toml' rust
    check_adjacent 'go.mod' 'go\.mod' go
    check_adjacent 'pyproject.toml' 'pyproject\.toml' python
    check_adjacent 'package.json' 'package\.json' node22
    check_adjacent 'CMakeLists.txt' 'CMakeLists\.txt' cpp
    check_adjacent 'build.gradle.kts' 'build\.gradle(\.kts)?' jvm

    touch "$out"
  ''
