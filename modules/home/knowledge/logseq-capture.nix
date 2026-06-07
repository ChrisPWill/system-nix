{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.logseq-capture;
in {
  options.services.logseq-capture = {
    enable = lib.mkEnableOption "Logseq Capture Bot";
    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/knowledge-base";
      description = "The directory containing the Logseq repository";
    };
  };

  # config = lib.mkIf cfg.enable (lib.mkMerge [
  # Disabled until I figure out the knowledge-base input
  config = lib.mkIf config.services.logseq-capture.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.services.logseq-capture = {
        Unit = {
          Description = "Logseq Capture Bot";
          After = ["network-online.target"];
        };
        Service = {
          ExecStart = "${inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/logseq-capture";
          Restart = "always";
          RestartSec = "10";
          WorkingDirectory = cfg.workingDirectory;
          EnvironmentFile = config.sops.secrets.logseq_capture_tokens.path;
        };
        Install.WantedBy = ["default.target"];
      };
    })

    (lib.mkIf pkgs.stdenv.isDarwin {
      launchd.agents.logseq-capture = {
        enable = true;
        config = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            "set -a; [ -f ${config.sops.secrets.logseq_capture_tokens.path} ] && . ${config.sops.secrets.logseq_capture_tokens.path}; set +a; exec ${inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/logseq-capture"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          WorkingDirectory = cfg.workingDirectory;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/logseq-capture.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/logseq-capture.log";
        };
      };
    })
  ]);
}
