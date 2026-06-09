{config, ...}: {
  programs.zsh.shellAliases = {
    nd = "f() { nix develop ${config.nixConfigDir}/.#$1 --command zsh };f";
  };

  programs.fish.shellAbbrs = {
    nfc = "nix flake check";
    nfu = "nix flake update";
    nsi = {
      expansion = "nix shell -p % --run fish";
      setCursor = true;
    };
  };
}
