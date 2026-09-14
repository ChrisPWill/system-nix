{
  config,
  lib,
  pkgs,
  ...
}: let
  # Docker's CLI only discovers subcommands like `compose` and `buildx` as
  # plugin binaries on disk. Docker Desktop shipped them inside its own
  # bundle; with a plain client we have to place them ourselves.
  cliPlugins = {
    docker-compose = pkgs.docker-compose;
    docker-buildx = pkgs.docker-buildx;
  };
in
  # Linux hosts get the daemon and CLI from virtualisation.docker instead.
  lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = [
      pkgs.colima
      pkgs.docker
    ];

    home.file = lib.mapAttrs' (name: drv:
      lib.nameValuePair ".docker/cli-plugins/${name}" {
        source = "${drv}/libexec/docker/cli-plugins/${name}";
      })
    cliPlugins;

    # macOS cannot run containers natively, so something has to hold a Linux
    # VM open for the socket to exist. Docker Desktop did this via a login
    # item; colima has no equivalent, so run it as a user agent to keep
    # `docker` usable straight after login without a manual `colima start`.
    launchd.agents.colima = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.colima}/bin/colima"
          "start"
          "--foreground"
        ];
        RunAtLoad = true;
        # Restart only on a crash. A plain `KeepAlive = true` would also
        # relaunch the VM the instant `colima stop` succeeded, which makes
        # reconfiguring it (e.g. `colima start --cpus 6`) a fight with
        # launchd.
        KeepAlive = {
          SuccessfulExit = false;
        };
        EnvironmentVariables = {
          HOME = config.home.homeDirectory;
        };
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/colima.launchd.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/colima.launchd.log";
      };
    };
  }
