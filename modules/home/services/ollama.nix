# NOTE: You will need to manually pull models, e.g.
# `ollama pull qwen2.5-coder:3b-base`
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.local-ollama;
in {
  options.services.local-ollama = {
    enable = mkEnableOption "Local Ollama server for LLM code completions";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.ollama];

    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama Local LLM Server";
        After = ["network.target"];
      };
      Service = {
        ExecStart = "${pkgs.ollama}/bin/ollama serve";
        Restart = "on-failure";
        Environment = [
          "OLLAMA_HOST=127.0.0.1:11434"
        ];
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
