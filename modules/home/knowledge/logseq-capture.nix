{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.logseq-capture;
  defaultJournal =
    if config.isPersonalMachine
    then "personal"
    else "work";
  commonAliases = {
    "lc" = "logseq-capture send";
    "lr" = "logseq-capture review today";
  };
in {
  options.services.logseq-capture = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the Logseq Capture Bot";
    };
    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/knowledge-base";
      description = "The directory containing the Logseq repository";
    };
  };

  # config = lib.mkIf cfg.enable (lib.mkMerge [
  # Disabled until I figure out the knowledge-base input
  config = lib.mkIf config.services.logseq-capture.enable (lib.mkMerge [
    {
      programs = {
        zsh.shellAliases = commonAliases;
        fish = {
          shellAliases = commonAliases;
          functions.brag = ''
            set -l timestamp (date '+%Y-%m-%d %H:%M:%S %z')
            logseq-capture send "$argv #brag [$timestamp]"
          '';
        };
        nushell.shellAliases = commonAliases;
      };
      home.packages = [
        inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.logseq-capture
      ];
      home.sessionVariables.LOGSEQ_CAPTURE_DEFAULT_JOURNAL = defaultJournal;
    }
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
          Environment = ["LOGSEQ_CAPTURE_DEFAULT_JOURNAL=${defaultJournal}"];
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
            "export LOGSEQ_CAPTURE_DEFAULT_JOURNAL=${defaultJournal}; set -a; [ -f ${config.sops.secrets.logseq_capture_tokens.path} ] && . ${config.sops.secrets.logseq_capture_tokens.path}; set +a; exec ${inputs.knowledge-base.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/logseq-capture"
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
