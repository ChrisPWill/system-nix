{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  kanataConfig = pkgs.writeText "kanata-global-leader.kbd" config.kanata.globalLeader.config;
  karabinerVirtualHid = rec {
    version = "6.2.0";
    rev = "c7df2059a84162d3d2d6784bebc887e888059375";
    receipt = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice";
    pkg = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/${rev}/dist/Karabiner-DriverKit-VirtualHIDDevice-${version}.pkg";
      hash = "sha256-noxGI58HSBYSQeQkRIV5ASJOXIL1tYoXMd9McL8HNqg=";
    };
    daemonPath = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
    managerPath = "/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  };
  kanataCommandArgs =
    [
      "${pkgs.kanata}/bin/kanata"
      "--cfg"
      "${kanataConfig}"
    ]
    ++ config.kanata.globalLeader.extraArgs;
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
  imports = [
    # Typical darwin configuration that isn't work or personal specific
    inputs.self.darwinModules.darwin-shared
    # Shared host settings across nixos and darwin
    inputs.self.nixosModules.host-shared
    # Cross-platform Caps Lock global leader configuration
    inputs.self.modules.kanata.global-leader
  ];

  homebrew = {
    brews = [
      "awscli"

      # Used for managing terraform versions. Simpler than nixifying for now
      # https://github.com/tofuutils/tenv
      "tenv"

      # For SignalFM
      "pipx"
    ];

    taps = [
      {
        name = "atlassian/lanyard";
        clone_target = "git@bitbucket.org:atlassian/lanyard-tap.git";
      }
      {
        name = "atlassian/cloudtoken";
        clone_target = "git@bitbucket.org:atlassian/cloudtoken-homebrew-tap.git";
        force_auto_update = true;
      }
    ];

    casks = [
      "cloudtoken"

      # AI VSCode wrapper
      "cursor"

      "docker-desktop"

      "google-drive"

      # Test requests
      "insomnia"

      # For testing Atlassian service calls
      "lanyard"

      # Screen recordings
      "loom"

      # Music
      "spotify"

      # Atlassian's browser
      "thebrowsercompany-dia"
    ];
  };

  environment.systemPackages = [
    pkgs.kanata
  ];

  system.activationScripts.extraActivation.text = lib.mkAfter ''
    karabiner_virtual_hid_version="${karabinerVirtualHid.version}"
    karabiner_virtual_hid_receipt="${karabinerVirtualHid.receipt}"
    karabiner_virtual_hid_installed_version="$(
      /usr/sbin/pkgutil --pkg-info "$karabiner_virtual_hid_receipt" 2>/dev/null \
        | /usr/bin/awk '/^version:/ { print $2; exit }' \
        || true
    )"

    if [ "$karabiner_virtual_hid_installed_version" != "$karabiner_virtual_hid_version" ]; then
      echo "installing Karabiner VirtualHIDDevice $karabiner_virtual_hid_version..." >&2
      /usr/sbin/installer -pkg "${karabinerVirtualHid.pkg}" -target /
    fi
  '';

  launchd.daemons."karabiner-vhidmanager" = {
    serviceConfig = {
      ProgramArguments = [
        karabinerVirtualHid.managerPath
        "activate"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      UserName = "root";
      StandardOutPath = "/var/log/karabiner-vhidmanager.log";
      StandardErrorPath = "/var/log/karabiner-vhidmanager.log";
    };
  };

  launchd.daemons."karabiner-vhiddaemon" = {
    serviceConfig = {
      ProgramArguments = [
        karabinerVirtualHid.daemonPath
      ];
      RunAtLoad = true;
      KeepAlive = true;
      UserName = "root";
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/karabiner-vhiddaemon.log";
      StandardErrorPath = "/var/log/karabiner-vhiddaemon.log";
    };
  };

  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = kanataCommandArgs;
      RunAtLoad = true;
      KeepAlive = true;
      UserName = "root";
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.log";
    };
  };

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

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "cwilliams-work-laptop";

  users.users.cwilliams.home = /Users/cwilliams;
  system.primaryUser = "cwilliams";

  # Every once in a while, a new nix-darwin release may change configuration defaults
  # in a way incompatible with stateful data. For instance, if the default version of
  # PostgreSQL changes, the new version will probably be unable to read your existing
  # databases. To prevent such breakage, you can set the value of this option to the
  # nix-darwin release with which you want to be compatible. The effect is that
  # nix-darwin will option defaults corresponding to the specified release (such as
  # using an older version of PostgreSQL).
  # It should be fine to leave this.
  system.stateVersion = 4; # did you read the comment?
}
