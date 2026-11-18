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
  # Not cached: atuin (Home Manager already writes a file for it), envoluntary
  # (its module has no switch to turn its own hook off), mise and carapace.
  # `mise activate` bakes the PATH it sees into its output, and carapace bakes
  # in its bin directory under $HOME, so a build-time copy would point at the
  # build sandbox instead of the real user.
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
