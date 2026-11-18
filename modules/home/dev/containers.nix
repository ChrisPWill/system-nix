{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.dev.containers.colima;

  # Docker's CLI only discovers subcommands like `compose` and `buildx` as
  # plugin binaries on disk. Docker Desktop shipped them inside its own
  # bundle; with a plain client we have to place them ourselves.
  cliPlugins = {
    inherit (pkgs) docker-compose docker-buildx;
  };
in {
  options.dev.containers.colima = {
    cpus = lib.mkOption {
      type = lib.types.ints.positive;
      # Sized for a local service stack plus Gradle integration tests on a
      # many-core laptop; four vCPUs left the VM saturated while the host idled.
      default = 8;
      description = "vCPUs for the Colima VM.";
    };
    memory = lib.mkOption {
      type = lib.types.ints.positive;
      # Colima's own default (2 GiB) is too small once a local service stack
      # and long-running tools such as Graphiti share the VM: the kernel's OOM
      # killer ends up picking off whichever container is largest.
      default = 16;
      description = "Memory for the Colima VM, in GiB.";
    };
    rosetta = lib.mkOption {
      type = lib.types.bool;
      default = true;
      # Some images, such as the Pub/Sub and Bigtable emulators, are
      # linux/amd64 only. Without Rosetta they run under QEMU user-mode
      # emulation, which is several times slower to start and run.
      description = "Run amd64 containers through Rosetta instead of QEMU.";
    };
  };

  # Linux hosts get the daemon and CLI from virtualisation.docker instead.
  config = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && config.appApproved.colima) {
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
        # Sizing flags are applied on every start, so the Nix options stay
        # authoritative over ~/.colima/default/colima.yaml.
        ProgramArguments = [
          "${pkgs.colima}/bin/colima"
          "start"
          "--foreground"
          "--cpus"
          (toString cfg.cpus)
          "--memory"
          (toString cfg.memory)
        ]
        ++ lib.optional cfg.rosetta "--vz-rosetta";
        RunAtLoad = true;
        # Restart only on a crash. A plain `KeepAlive = true` would also
        # relaunch the VM the instant `colima stop` succeeded, which makes
        # reconfiguring it a fight with launchd.
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
  };
}
