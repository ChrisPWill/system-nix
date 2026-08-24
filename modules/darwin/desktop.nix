{
  config,
  lib,
  pkgs,
  ...
}: let
  primaryUser = config.system.primaryUser;
  primaryUserHome = "/Users/${primaryUser}";
  omniwmLaunchScript = pkgs.writeShellScript "launch-omniwm-after-kanata" ''
    /bin/wait4path /nix/store

    attempts=0
    while [ "$attempts" -lt 75 ]; do
      if /bin/launchctl print system/org.nixos.kanata 2>/dev/null | /usr/bin/grep -q "state = running"; then
        break
      fi

      attempts=$((attempts + 1))
      /bin/sleep 0.2
    done

    /bin/sleep 1
    exec /usr/bin/open -a OmniWM
  '';

  # `brew bundle` (run as part of `sw`) upgrades cask app bundles on disk in
  # place, but never restarts whatever GUI process already has the old
  # bundle open. A long-lived app (OmniWM, Docker Desktop) then keeps running
  # old code against files that no longer match on disk: OmniWM's IPC
  # protocol version drifts from `omniwmctl` (breaking every OmniWM skhd
  # binding with "protocol_mismatch") and Docker's helper processes can end
  # up in a similarly inconsistent state. Neither failure mode is loud, so
  # check for it explicitly rather than waiting to notice hotkeys are dead.
  staleCaskApps = [
    {
      name = "OmniWM";
      bundle = "/Applications/OmniWM.app";
      binary = "/Applications/OmniWM.app/Contents/MacOS/OmniWM";
      restartHint = "osascript -e 'quit app \"OmniWM\"'; open -a OmniWM";
    }
    {
      name = "Docker Desktop";
      bundle = "/Applications/Docker.app";
      binary = "/Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/MacOS/Docker Desktop";
      restartHint = "osascript -e 'quit app \"Docker\"'; open -a Docker";
    }
  ];

  staleCaskAppsCheckScript = pkgs.writeShellScriptBin "stale-cask-apps-check" ''
    set -u
    status=0

    names=(${lib.concatMapStringsSep " " (app: lib.escapeShellArg app.name) staleCaskApps})
    bundles=(${lib.concatMapStringsSep " " (app: lib.escapeShellArg app.bundle) staleCaskApps})
    binaries=(${lib.concatMapStringsSep " " (app: lib.escapeShellArg app.binary) staleCaskApps})
    restart_hints=(${lib.concatMapStringsSep " " (app: lib.escapeShellArg app.restartHint) staleCaskApps})

    for i in "''${!names[@]}"; do
      name="''${names[$i]}"
      bundle="''${bundles[$i]}"
      binary="''${binaries[$i]}"
      restart_hint="''${restart_hints[$i]}"

      if [ ! -d "$bundle" ]; then
        continue
      fi

      # Anchor to the start of the command line so this only matches the
      # binary actually being launched (which may take its own args, e.g.
      # Docker Desktop's `--reason=open-tray ...`), not `pgrep -f`'s default
      # substring search: that would also match unrelated processes whose
      # argv happens to quote this same path (e.g. the shell invoking this
      # very check), producing a garbage multi-pid result.
      pid="$(/usr/bin/pgrep -n -f "^$binary( |$)" 2>/dev/null || true)"
      if [ -z "$pid" ]; then
        /bin/echo "SKIP: $name is not running."
        continue
      fi

      # Compare when the running process was exec'd against when the
      # bundle on disk was last modified (a brew upgrade rewrites files
      # inside it). If the bundle is newer, this process predates the
      # upgrade and is still serving old code/protocol.
      # Force a fixed locale: `ps`'s lstart wording/ordering otherwise
      # varies with the user's locale, breaking the fixed `date -f` format
      # below.
      started_epoch="$(LC_ALL=C /bin/ps -o lstart= -p "$pid" 2>/dev/null | /usr/bin/xargs -I{} /bin/date -j -f "%a %b %d %T %Y" "{}" "+%s" 2>/dev/null || true)"
      bundle_epoch="$(/usr/bin/stat -f "%m" "$bundle" 2>/dev/null || true)"

      if [ -z "$started_epoch" ] || [ -z "$bundle_epoch" ]; then
        /bin/echo "INCONCLUSIVE: could not compare $name's process start time to its bundle mtime."
        continue
      fi

      if [ "$bundle_epoch" -gt "$started_epoch" ]; then
        /bin/echo "FAIL: $name (pid $pid) has been running since before its last brew upgrade." >&2
        /bin/echo "  The app on disk has changed underneath it; restart to pick up the new build:" >&2
        /bin/echo "  $restart_hint" >&2
        status=1
      else
        /bin/echo "OK: $name (pid $pid) started after its bundle was last updated."
      fi
    done

    exit "$status"
  '';
in {
  environment.systemPackages = [staleCaskAppsCheckScript];

  homebrew.casks = [
    "cleanshot"
    "docker-desktop"
    "ghostty"
    "imageoptim"
    "omniwm"
    "raycast"
    "scroll-reverser"
    "vivaldi"
  ];

  launchd.user.agents.omniwm = {
    serviceConfig = {
      ProgramArguments = [
        "${omniwmLaunchScript}"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
      StandardOutPath = "${primaryUserHome}/Library/Logs/omniwm.launchd.log";
      StandardErrorPath = "${primaryUserHome}/Library/Logs/omniwm.launchd.log";
    };
  };
}
