{
  config,
  lib,
  pkgs,
  ...
}: let
  flakePath = config.nixConfigDir;
  homeUsername = config.home.username;
  nhWrapper = name: text:
    pkgs.writeShellApplication {
      inherit name text;
      runtimeInputs = [config.programs.nh.package];
    };
  nhWrapperPrelude = ''
    flake=${lib.escapeShellArg flakePath}
    home_user=${lib.escapeShellArg homeUsername}

    current_hostname() {
      local value
      value="$(hostname -s 2>/dev/null || hostname 2>/dev/null)"
      value="''${value%%.*}"

      if [[ -z "$value" ]]; then
        printf '%s\n' 'Could not determine the current hostname.' >&2
        exit 1
      fi

      printf '%s\n' "$value"
    }

    has_option() {
      local short="$1"
      local long="$2"
      shift 2

      local arg
      for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
          return 1
        fi

        case "$arg" in
          "$short" | "$long" | "$long"=*) return 0 ;;
        esac
      done

      return 1
    }

    hostname_args() {
      if has_option '-H' '--hostname' "$@"; then
        return
      fi

      printf '%s\n' '--hostname' "$(current_hostname)"
    }

    home_configuration_args() {
      if has_option '-c' '--configuration' "$@"; then
        return
      fi

      printf '%s\n' '--configuration' "$home_user@$(current_hostname)"
    }
  '';
in {
  programs = {
    nh = {
      enable = true;
      flake = config.nixConfigDir;
      homeFlake = config.nixConfigDir;
      osFlake = config.nixConfigDir;
      darwinFlake = config.nixConfigDir;
    };

    zsh.shellAliases = {
      nd = "f() { nix develop ${config.nixConfigDir}/.#$1 --command zsh };f";
    };

    fish.shellAbbrs = {
      nfc = "nix flake check";
      nfu = "nix flake update";
      nsi = {
        expansion = "nix shell -p % --run fish";
        setCursor = true;
      };
    };
  };

  home.packages = [
    (nhWrapper "sw" ''
      ${nhWrapperPrelude}

      mapfile -t host_args < <(hostname_args "$@")
      mapfile -t home_args < <(home_configuration_args "$@")

      case "$(uname -s)" in
        Darwin)
          exec nh darwin switch "$flake" "''${host_args[@]}" "$@"
          ;;
        Linux)
          if [[ -e /etc/NIXOS ]]; then
            exec nh os switch "$flake" "''${host_args[@]}" "$@"
          fi

          exec nh home switch "$flake" "''${home_args[@]}" "$@"
          ;;
        *)
          exec nh home switch "$flake" "''${home_args[@]}" "$@"
          ;;
      esac
    '')
    (nhWrapper "hms" ''
      ${nhWrapperPrelude}

      mapfile -t home_args < <(home_configuration_args "$@")

      printf '%s\n' 'hms is deprecated; use sw or nh home switch.' >&2
      exec nh home switch "$flake" "''${home_args[@]}" "$@"
    '')
    (nhWrapper "drs" ''
      ${nhWrapperPrelude}

      mapfile -t host_args < <(hostname_args "$@")

      printf '%s\n' 'drs is deprecated; use sw or nh darwin switch.' >&2
      exec nh darwin switch "$flake" "''${host_args[@]}" "$@"
    '')
    (nhWrapper "nrs" ''
      ${nhWrapperPrelude}

      mapfile -t host_args < <(hostname_args "$@")

      printf '%s\n' 'nrs is deprecated; use sw or nh os switch.' >&2
      exec nh os switch "$flake" "''${host_args[@]}" "$@"
    '')
  ];
}
