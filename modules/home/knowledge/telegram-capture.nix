{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.telegram-capture;
in {
  options.services.telegram-capture = {
    enable = lib.mkEnableOption "Logseq Telegram Capture Bot";
    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/knowledge-base";
      description = "The directory containing the Logseq repository";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.services.telegram-capture = {
        Unit = {
          Description = "Logseq Telegram Capture Bot";
          After = ["network-online.target"];
        };
        Service = {
          ExecStart = "${inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/telegram-capture";
          Restart = "always";
          RestartSec = "10";
          WorkingDirectory = cfg.workingDirectory;
          EnvironmentFile = config.sops.secrets.telegram_kb_capture_token.path;
        };
        Install.WantedBy = ["default.target"];
      };
    })

    (lib.mkIf pkgs.stdenv.isDarwin {
      launchd.agents.telegram-capture = {
        enable = true;
        config = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            "set -a; [ -f ${config.sops.secrets.telegram_kb_capture_token.path} ] && . ${config.sops.secrets.telegram_kb_capture_token.path}; set +a; exec ${inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/telegram-capture"
            ];
            RunAtLoad = true;
            KeepAlive = true;
            WorkingDirectory = cfg.workingDirectory;
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/telegram-capture.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/telegram-capture.log";
            };
            })
            ]);
            }
}
