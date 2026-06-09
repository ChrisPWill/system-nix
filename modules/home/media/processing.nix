{pkgs, ...}: {
  home.packages = with pkgs; [
    # Conversions etc.
    imagemagick
    ffmpeg
  ];

  programs.fish.shellAbbrs = {
    iconvert = {
      expansion = "magick % output.png";
      setCursor = true;
    };

    vconvert = {
      expansion = "ffmpeg -i % output.mp4";
      setCursor = true;
    };
  };
}
