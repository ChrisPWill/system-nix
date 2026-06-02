{
  config,
  inputs,
  ...
}: {
  imports = [inputs.self.modules.kanata.global-leader];

  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        extraArgs = config.kanata.globalLeader.extraArgs;
        config = config.kanata.globalLeader.config;
      };
    };
  };
}
