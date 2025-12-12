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

      "inode/directory" = "dolphin.desktop";
    };
  };
}
