{
  config,
  lib,
  pkgs,
  ...
}: let
  kanataConfig = pkgs.writeText "kanata-global-leader.kbd" ''
    (defcfg
      ${config.kanata.globalLeader.defcfg}
    )

    ${config.kanata.globalLeader.config}
  '';
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
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
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
  };
}
