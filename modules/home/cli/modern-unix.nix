{pkgs, ...}: {
  home.packages = with pkgs; [
    # Fast alternative to find
    # https://github.com/sharkdp/fd
    fd

    # Fast grep
    ripgrep

    # Rust-based ps replacement
    procs

    # Watch progress of cp/mv/dd/tar/etc. `tldr progress` for info
    progress
  ];

  # Nice colourful cat alternative
  # https://github.com/sharkdp/bat
  programs.bat.enable = true;

  # Auto use flakes when in directory (and allowed)
  # Remember to `direnv allow` in a project to get it going
  programs.direnv.enable = true;

  # ls alternative
  # https://github.com/eza-community/eza
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  # Nice fast autojump command
  # https://github.com/ajeetdsouza/zoxide
  programs.zoxide.enable = true;

  # Command history
  programs.atuin.enable = true;

  # Autocompletion in shell
  programs.carapace.enable = true;
}
