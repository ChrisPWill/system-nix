{
  config,
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
in {
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
