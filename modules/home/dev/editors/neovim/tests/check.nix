{
  language,
  pkgs,
  perSystem,
  ...
}: let
  meow = perSystem.self.meow;
  testRoot = ./.;
  fixtureRoot = "${testRoot}/fixtures/${language}";
  harness = "${testRoot}/lsp_harness.lua";

  cases = {
    python = {
      file = "main.py";
      clients = "ruff";
      trigger = "fixture_target_al";
      completion = "";
      executables = "basedpyright,ruff";
      formatter = "ruff_organize_imports";
      linter = "";
      expectDiagnostics = true;
    };
    typescript = {
      file = "src/main.ts";
      clients = "typescript-tools";
      trigger = "fixtureTargetAl";
      completion = "fixtureTargetAlpha";
      executables = "typescript-language-server,prettierd";
      formatter = "prettierd";
      linter = "eslint_d";
      expectDiagnostics = true;
    };
    kotlin = {
      file = "src/main/kotlin/Main.kt";
      clients = "kotlin_language_server";
      trigger = "fixtureTargetAl";
      completion = "fixtureTargetAlpha";
      executables = "kotlin-language-server,ktlint";
      formatter = "ktlint";
      linter = "ktlint";
      expectDiagnostics = false;
    };
  };

  case = cases.${language};
in
  pkgs.runCommand "neovim-lsp-${language}-check" {
    nativeBuildInputs = [pkgs.coreutils];
    meta.platforms = pkgs.lib.platforms.linux;
  } ''
    set -euo pipefail

    work="$TMPDIR/work"
    home="$TMPDIR/home"
    state="$TMPDIR/state"
    cache="$TMPDIR/cache"
    data="$TMPDIR/data"
    report="$TMPDIR/neovim-lsp-${language}-report.txt"
    lsp_log="$TMPDIR/neovim-lsp-${language}-lsp.log"

    mkdir -p "$work" "$home" "$state" "$cache" "$data"
    cp -R ${fixtureRoot}/. "$work/"
    chmod -R u+w "$work"

    export HOME="$home"
    export XDG_CONFIG_HOME="$home/.config"
    export XDG_STATE_HOME="$state"
    export XDG_CACHE_HOME="$cache"
    export XDG_DATA_HOME="$data"
    export NVIM_LSP_LOG_FILE="$lsp_log"
    export NVIM_LSP_TEST_REPORT="$report"
    export NVIM_LSP_TEST_FILE="$work/${case.file}"
    export NVIM_LSP_TEST_CLIENTS="${case.clients}"
    export NVIM_LSP_TEST_TRIGGER="${case.trigger}"
    export NVIM_LSP_TEST_COMPLETION="${case.completion}"
    export NVIM_LSP_TEST_EXECUTABLES="${case.executables}"
    export NVIM_LSP_TEST_FORMATTER="${case.formatter}"
    export NVIM_LSP_TEST_LINTER="${case.linter}"
    export NVIM_LSP_TEST_EXPECT_DIAGNOSTICS="${
      if case.expectDiagnostics
      then "1"
      else "0"
    }"

    set +e
    ${meow}/bin/meow --headless -n --cmd 'lua vim.lsp.set_log_level("debug")' -l ${harness}
    nvim_status=$?
    set -e

    if [ "$nvim_status" -ne 0 ]; then
      echo "neovim-lsp ${language} failed"
      test -f "$report" && cat "$report"
      test -f "$lsp_log" && cat "$lsp_log"
      exit 1
    fi

    mkdir -p "$out/logs"
    if [ ! -f "$report" ]; then
      echo "Neovim exited successfully but did not write a report." > "$report"
    fi
    cp "$report" "$out/logs/neovim-lsp-${language}-report.txt"
    if [ -f "$lsp_log" ]; then
      cp "$lsp_log" "$out/logs/neovim-lsp-${language}-lsp.log"
    fi
  ''
