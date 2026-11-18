{
  config,
  lib,
  pkgs,
  ...
}: let
  # Each integration below normally runs `tool init fish | source`, which forks
  # the tool on every new shell (about 15-45ms each). The script a given tool
  # version prints never changes, so generate it once at build time and source
  # the file instead. A new tool version gives a new store path, so the cache
  # can't go stale.
  #
  # Not cached: atuin (Home Manager already writes a file for it) and
  # envoluntary (its module has no switch to turn its own hook off).
  cached = [
    {
      name = "zoxide";
      args = "init fish";
    }
    {
      name = "starship";
      # `starship init fish` only prints a stub that forks starship again to
      # fetch the real script; ask for that script directly.
      args = "init fish --print-full-init";
      guard = ''test "$TERM" != dumb'';
    }
    {
      name = "mise";
      args = "activate fish";
    }
    {
      name = "carapace";
      args = "_carapace fish";
    }
    {
      name = "direnv";
      args = "hook fish";
    }
  ];

  enabled = builtins.filter (t: config.programs.${t.name}.enable) cached;

  initFile = t:
    pkgs.runCommand "${t.name}-init.fish" {} ''
      export HOME=$TMPDIR
      ${lib.getExe config.programs.${t.name}.package} ${t.args} > $out
    '';

  sourceLine = t: let
    src = "source ${initFile t}";
  in
    if t ? guard
    then ''
      if ${t.guard}
          ${src}
      end
    ''
    else src;
in {
  # Attribute names must not depend on `config`, or the module system recurses
  # while working out which options exist; only the values may.
  config = lib.mkIf config.programs.fish.enable {
    programs =
      builtins.listToAttrs (map (t:
        lib.nameValuePair t.name {
          enableFishIntegration = lib.mkIf config.programs.${t.name}.enable false;
        })
      cached)
      // {
        fish.interactiveShellInit = lib.mkAfter (lib.concatMapStringsSep "\n" sourceLine enabled);
      };
  };
}
