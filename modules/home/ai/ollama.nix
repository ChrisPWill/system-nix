{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.local-ollama;

  ollamaPkg =
    if config.hasNvidiaGpu
    then pkgs.ollama-cuda
    else pkgs.ollama;

  host = "127.0.0.1:11434";

  environment =
    {OLLAMA_HOST = host;}
    // optionalAttrs (cfg.contextLength != null) {
      OLLAMA_CONTEXT_LENGTH = toString cfg.contextLength;
    }
    // optionalAttrs (cfg.keepAlive != null) {
      OLLAMA_KEEP_ALIVE = cfg.keepAlive;
    };

  # `ollama pull` only fetches layers that changed upstream, so re-running it
  # on every login is cheap once the models are present.
  pullModels = pkgs.writeShellApplication {
    name = "ollama-pull-models";
    runtimeInputs = [ollamaPkg pkgs.curl];
    runtimeEnv.OLLAMA_HOST = host;
    text = ''
      until curl -fsS "http://${host}/api/version" >/dev/null; do
        sleep 2
      done
      ${concatMapStringsSep "\n" (model: "ollama pull ${escapeShellArg model}") cfg.models}
    '';
  };

  logDir = "${config.home.homeDirectory}/Library/Logs";
in {
  options.services.local-ollama = {
    enable = mkEnableOption "Local Ollama server for LLM code completions";

    models = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Models pulled automatically once the server is up. Other modules append the models they depend on.";
    };

    contextLength = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        Default context window for loaded models. Ollama's own default is small
        and silently truncates longer prompts rather than erroring.
      '';
    };

    keepAlive = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10m";
      description = "How long an idle model stays in memory before being unloaded.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ollamaPkg];
    }

    (mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.ollama = {
        Unit = {
          Description = "Ollama Local LLM Server";
          After = ["network.target"];
        };
        Service = {
          ExecStart = "${ollamaPkg}/bin/ollama serve";
          Restart = "on-failure";
          Environment = mapAttrsToList (name: value: "${name}=${value}") environment;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      systemd.user.services.ollama-pull-models = mkIf (cfg.models != []) {
        Unit = {
          Description = "Pull configured Ollama models";
          After = ["ollama.service"];
          Wants = ["ollama.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = getExe pullModels;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };
    })

    # Run natively rather than in a container: Docker on macOS has no Metal
    # access, so a containerised Ollama would be CPU-only.
    (mkIf pkgs.stdenv.hostPlatform.isDarwin {
      launchd.agents.ollama = {
        enable = true;
        config = {
          ProgramArguments = ["${ollamaPkg}/bin/ollama" "serve"];
          RunAtLoad = true;
          KeepAlive = {
            SuccessfulExit = false;
          };
          EnvironmentVariables = environment // {HOME = config.home.homeDirectory;};
          StandardOutPath = "${logDir}/ollama.launchd.log";
          StandardErrorPath = "${logDir}/ollama.launchd.log";
        };
      };

      launchd.agents.ollama-pull-models = mkIf (cfg.models != []) {
        enable = true;
        config = {
          ProgramArguments = [(getExe pullModels)];
          RunAtLoad = true;
          EnvironmentVariables.HOME = config.home.homeDirectory;
          StandardOutPath = "${logDir}/ollama-pull-models.launchd.log";
          StandardErrorPath = "${logDir}/ollama-pull-models.launchd.log";
        };
      };
    })
  ]);
}
