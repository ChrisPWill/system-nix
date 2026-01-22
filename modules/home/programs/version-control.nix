{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Neat TUI for jujutsu
    # https://github.com/Cretezy/lazyjj
    lazyjj

    # Another fancy git UI
    tig
  ];

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      IgnoreUnknown UseKeychain
      UseKeychain yes
    '';

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        compression = true;
        forwardAgent = true;
        serverAliveCountMax = 2;
        serverAliveInterval = 300;
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
  programs.nushell.shellAliases.lg = "lazygit";

  # https://jj-vcs.github.io/jj/latest/
  # VCS built on top of git
  # Experimenting with this for personal projects
  programs.jujutsu.enable = true;
  programs.jujutsu.settings.user.name = "Chris Williams";
  programs.jujutsu.settings.user.email = config.userEmail;
  # LazyJJ - easy TUI for jujutsu VCS
  programs.zsh.shellAliases.ljj = "lazyjj";
  programs.nushell.shellAliases.ljj = "lazyjj";
}
