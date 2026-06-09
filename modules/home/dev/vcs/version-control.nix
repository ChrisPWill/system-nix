{
  config,
  lib,
  pkgs,
  ...
}: let
  scriptDir = "${config.homeModuleDir}/dev/vcs/scripts";
in {
  home.packages = with pkgs; [
    # Neat TUI for jujutsu
    # https://github.com/Cretezy/lazyjj
    lazyjj

    # Another fancy git UI
    tig
  ];

  home.sessionPath = [scriptDir];
  programs.nushell.extraEnv = ''
    $env.PATH = ($env.PATH | split row (char esep) | append "${scriptDir}")
  '';

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      IgnoreUnknown UseKeychain
      UseKeychain yes
    '';

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        Compression = true;
        ForwardAgent = true;
        ServerAliveCountMax = 2;
        ServerAliveInterval = 300;
      };
    };
  };

  programs.git = {
    enable = true;

    lfs.enable = true;

    settings = {
      user.name = "Chris Williams";
      user.email = config.userEmail;
      push.autoSetupRemote = true;
      core = {
        # Improved performance on MacOS
        # https://github.blog/2022-06-29-improve-git-monorepo-performance-with-a-file-system-monitor/
        fsmonitor = true;
        untrackedcache = true;
      };
    };
  };
  programs.diff-so-fancy.enable = true;

  # Neat TUI for git
  # https://github.com/jesseduffield/lazygit
  programs.lazygit.enable = true;
  programs.zsh.shellAliases.lg = "lazygit";
  programs.fish.shellAliases.lg = "lazygit";
  programs.nushell.shellAliases.lg = "lazygit";

  # https://jj-vcs.github.io/jj/latest/
  # VCS built on top of git
  # Experimenting with this for personal projects
  programs.jujutsu.enable = true;
  programs.jujutsu.settings = {
    user.name = "Chris Williams";
    user.email = config.userEmail;

    fix.tools.treefmt = {
      command = ["nix" "fmt" "--" "--stdin" "$path"];
      patterns = ["glob:**/*"];
    };

    # Workaround for lack of native pre-push hooks
    aliases.push = ["util" "exec" "--" "sh" "-c" "nix flake check && jj git push \"$@\"" "--"];
  };
  # LazyJJ - easy TUI for jujutsu VCS
  programs.zsh.shellAliases.ljj = "lazyjj";
  programs.fish.shellAliases.ljj = "lazyjj";
  programs.nushell.shellAliases.ljj = "lazyjj";
}
