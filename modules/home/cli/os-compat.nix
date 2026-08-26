# Cross-platform command-name compatibility.
#
# Abbreviations rather than aliases: these mappings share a name with their
# counterpart but not a flag set, so expanding in place keeps the real command
# visible before it runs.
{
  lib,
  pkgs,
  ...
}: let
  # Linux command names, mapped to their macOS equivalents.
  darwinAbbrs = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    xdg-open = "open";
    lsblk = "diskutil list";
    port = {
      expansion = "lsof -nP -iTCP:%<port> -sTCP:LISTEN";
      setCursor = true;
    };
    flushdns = "sudo dscacheutil -flushcache; and sudo killall -HUP mDNSResponder";
    ss = "lsof -iTCP -sTCP:LISTEN -n -P";
    xclip = "pbcopy";
    xclip-o = "pbpaste";
    free = "memory_pressure";
    journalctl = "log show --last 1h";
    journalctl-f = "log stream --level info";
    locate = "mdfind -name";
    ldd = "otool -L";
    lshw = "system_profiler SPHardwareDataType";
    dmidecode = "system_profiler SPHardwareDataType";

    # Not named `suspend`, which would shadow Fish's builtin of that name.
    sleepnow = "pmset sleepnow";
    systemctl-suspend = "pmset sleepnow";

    sensors = "macmon";
    powertop = "macmon";
  };

  # The reverse direction: macOS names that muscle memory reaches for on Linux.
  # Clipboard access assumes Wayland, matching the only graphical Linux host.
  linuxAbbrs = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    open = "xdg-open";
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };
in {
  programs.fish.shellAbbrs = darwinAbbrs // linuxAbbrs;

  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # Reads Apple Silicon sensors without sudo, unlike powermetrics
    # https://github.com/vladkens/macmon
    pkgs.macmon
  ];
}
