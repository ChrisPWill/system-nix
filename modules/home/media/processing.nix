{pkgs, ...}: {
  home.packages = with pkgs; [
    # Conversions etc.
    imagemagick
    ffmpeg
  ];
}
