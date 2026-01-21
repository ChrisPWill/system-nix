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
  services.ssh-agent.enableZshIntegration = true;
  services.ssh-agent.enableFishIntegration = config.programs.fish.enable;
  services.ssh-agent.enableNushellIntegration = config.programs.nushell.enable;
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
  programs.diff-so-fancy.enableGitIntegration = true;

  # Neat TUI for git
  # https://github.com/jesseduffield/lazygit
  programs.lazygit.enable = true;
  programs.lazygit.enableZshIntegration = true;
  programs.lazygit.enableFishIntegration = config.programs.fish.enable;
  programs.lazygit.enableNushellIntegration = config.programs.nushell.enable;
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
