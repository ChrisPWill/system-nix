{
  pkgs,
  perSystem,
  ...
}:
pkgs.runCommand "neovim-base-dormant-check" {
  nativeBuildInputs = [pkgs.coreutils];
} ''
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_STATE_HOME="$HOME/.local/state"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_DATA_HOME="$HOME/.local/share"
  export NVIM_BASE_TEST_FILE=${../modules/home/dev/editors/neovim/tests/fixtures/nix/default.nix}
  export NVIM_BASE_TEST_RUST_FILE="$TMPDIR/main.rs"
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
  touch "$NVIM_BASE_TEST_RUST_FILE"

  ${perSystem.self.meow}/bin/meow --headless -n \
    -l ${../modules/home/dev/editors/neovim/tests/base_harness.lua}

  touch "$out"
''
