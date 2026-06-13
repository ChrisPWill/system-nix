{
  config,
  pkgs,
  ...
}: let
  nhWrapper = name: text:
    pkgs.writeShellApplication {
      inherit name text;
      runtimeInputs = [config.programs.nh.package];
    };
in {
  programs.nh = {
    enable = true;
    flake = config.nixConfigDir;
    homeFlake = config.nixConfigDir;
    osFlake = config.nixConfigDir;
    darwinFlake = config.nixConfigDir;
  };

  home.packages = [
    (nhWrapper "nhs" ''
      case "$(uname -s)" in
        Darwin)
          exec nh darwin switch "$@"
          ;;
        Linux)
          if [[ -e /etc/NIXOS ]]; then
            exec nh os switch "$@"
          fi

          exec nh home switch "$@"
          ;;
        *)
          exec nh home switch "$@"
          ;;
      esac
    '')
    (nhWrapper "hms" ''
      printf '%s\n' 'hms is deprecated; use nhs or nh home switch.' >&2
      exec nh home switch "$@"
    '')
    (nhWrapper "drs" ''
      printf '%s\n' 'drs is deprecated; use nhs or nh darwin switch.' >&2
      exec nh darwin switch "$@"
    '')
    (nhWrapper "nrs" ''
      printf '%s\n' 'nrs is deprecated; use nhs or nh os switch.' >&2
      exec nh os switch "$@"
    '')
  ];

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
