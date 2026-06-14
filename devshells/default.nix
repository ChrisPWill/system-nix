{pkgs, ...}: let
  gitBin = "${pkgs.git}/bin/git";
in
  pkgs.mkShell {
    packages = with pkgs; [
      git
    ];

    shellHook = ''
      repo_root="$(${gitBin} rev-parse --show-toplevel 2>/dev/null || true)"

      if [ -n "$repo_root" ] && [ -d "$repo_root/.githooks" ]; then
        hooks_path="$(${gitBin} -C "$repo_root" config --local --get core.hooksPath || true)"

        if [ "$hooks_path" != ".githooks" ]; then
          ${gitBin} -C "$repo_root" config --local core.hooksPath .githooks
          printf '%s\n' "Configured Git hooks: core.hooksPath=.githooks" >&2
        fi
      fi
    '';
  }
