{
  config,
  lib,
  pkgs,
  ...
}: let
  flakePath = config.nixConfigDir;
  homeUsername = config.home.username;
  flakeHostName = config.dev.nix.flakeHostName;
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
      value=${lib.escapeShellArg (lib.optionalString (flakeHostName != null) flakeHostName)}
      if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
        return
      fi

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
  options.dev.nix.separateHomeManager = lib.mkEnableOption ''
    switching Home Manager on its own, without sudo. `sw` then switches only
    Home Manager, and on macOS `sw-system` switches nix-darwin. The host's
    nix-darwin config must leave out Home Manager
  '';

  options.dev.nix.flakeHostName = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "cwilliams-intuit-laptop";
    description = ''
      Directory under hosts/ that `sw` builds. Null uses this machine's
      hostname. Set it where IT names the machine and changing the hostname
      needs admin rights.
    '';
  };

  config.programs = {
    nh = {
      enable = config.appApproved.nh;
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

  # sw and sw-system are wrappers around nh.
  config.home.packages = lib.optionals config.appApproved.nh (
    [
      (nhWrapper "sw" (
        if config.dev.nix.separateHomeManager
        then ''
          ${nhWrapperPrelude}

          mapfile -t home_args < <(home_configuration_args "$@")
          exec nh home switch "$flake" "''${home_args[@]}" "$@"
        ''
        else ''
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
        ''
      ))
    ]
    ++ lib.optionals (config.dev.nix.separateHomeManager && pkgs.stdenv.hostPlatform.isDarwin) [
      (nhWrapper "sw-system" ''
        ${nhWrapperPrelude}

        mapfile -t host_args < <(hostname_args "$@")
        exec nh darwin switch "$flake" "''${host_args[@]}" "$@"
      '')
    ]
  );
}
