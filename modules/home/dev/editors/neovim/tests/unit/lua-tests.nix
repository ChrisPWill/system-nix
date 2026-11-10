{
  inputs,
  pkgs,
  ...
}: let
  meow = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.meow;
  # The whole Neovim folder, not just tests/unit, so specs can read files
  # under config/ by their path relative to the spec.
  neovimRoot = ../..;
in
  pkgs.runCommandLocal "neovim-lua-tests-check" {
    nativeBuildInputs = [pkgs.coreutils];
  } ''
    set -euo pipefail

    home="$TMPDIR/home"
    state="$TMPDIR/state"
    cache="$TMPDIR/cache"
    data="$TMPDIR/data"
    mkdir -p "$home" "$state" "$cache" "$data"

    export HOME="$home"
    export XDG_CONFIG_HOME="$home/.config"
    export XDG_STATE_HOME="$state"
    export XDG_CACHE_HOME="$cache"
    export XDG_DATA_HOME="$data"

    set +e
    ${meow}/bin/meow --headless -n -l ${neovimRoot}/tests/unit/run_specs.lua > "$TMPDIR/output.log" 2>&1
    status=$?
    set -e

    cat "$TMPDIR/output.log"

    if [ "$status" -ne 0 ]; then
      echo "neovim-lua-tests failed"
      exit 1
    fi

    mkdir -p "$out/logs"
    cp "$TMPDIR/output.log" "$out/logs/neovim-lua-tests-report.txt"
  ''
