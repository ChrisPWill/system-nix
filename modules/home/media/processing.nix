{
  config,
  lib,
  pkgs,
  ...
}: let
  approved = config.appApproved;
in {
  # Conversions etc.
  home.packages =
    lib.optionals approved.imagemagick [pkgs.imagemagick]
    ++ lib.optionals approved.ffmpeg [pkgs.ffmpeg];

  programs.fish.shellAbbrs =
    lib.optionalAttrs approved.imagemagick {
      iconvert = {
        expansion = "magick % output.png";
        setCursor = true;
      };
    }
    // lib.optionalAttrs approved.ffmpeg {
      vconvert = {
        expansion = "ffmpeg -i % output.mp4";
        setCursor = true;
      };
    };
}
