{pkgs, ...}: {
  home.packages = with pkgs; [
    # Matrix chat
    element-desktop
  ];
}
