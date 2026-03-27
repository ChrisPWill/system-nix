{pkgs, ...}: {
  home.packages = with pkgs; [
    tealdeer
  ];

  # FZF replacement
  # Use Ctrl-T for smart finding on lots of commands
  programs.television = {
    enable = true;
    settings = {
      ui.theme = "onedark";
    };
  };
}
