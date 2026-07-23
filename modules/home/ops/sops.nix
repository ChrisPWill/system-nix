{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = {
    home.packages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      validateSopsFiles = false;

      age = {
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };

      secrets =
        {
          logseq_capture_tokens = {};
        }
        // lib.optionalAttrs (config.home.ai.neovimProvider == "gemini") {
          gemini_api_key = {};
        };
    };
  };
}
