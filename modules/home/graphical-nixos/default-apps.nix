{...}: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = let
      vivaldi = "vivaldi-stable.desktop";
    in {
      # Browser
      "text/html" = vivaldi;
      "x-scheme-handler/http" = vivaldi;
      "x-scheme-handler/https" = vivaldi;
      "x-scheme-handler/about" = vivaldi;
      "x-scheme-handler/unknown" = vivaldi;
      "application/pdf" = vivaldi;

      # File management
      "inode/directory" = "dolphin.desktop";

      # Image viewing
      "image/jpeg" = "qimgv.desktop";
      "image/png" = "qimgv.desktop";
      "image/gif" = "qimgv.desktop";
      "image/bmp" = "qimgv.desktop";
      "image/webp" = "qimgv.desktop";
      "image/tiff" = "qimgv.desktop";
      "image/svg+xml" = "qimgv.desktop";
      "image/x-xcf" = "qimgv.desktop"; # GIMP's native format
      "image/vnd.adobe.photoshop" = "qimgv.desktop"; # PSD files
    };

    associations.removed = let
      vivaldi = "vivaldi-stable.desktop";
    in {
      "image/jpeg" = [vivaldi];
      "image/png" = [vivaldi];
      "image/gif" = [vivaldi];
      "image/bmp" = [vivaldi];
      "image/webp" = [vivaldi];
      "image/tiff" = [vivaldi];
      "image/svg+xml" = [vivaldi];
    };
  };
}
