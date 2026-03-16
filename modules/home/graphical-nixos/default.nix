{
  inputs,
  pkgs,
  ...
}: let
  dmsPlugins = pkgs.fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "889760cbeefe175dd1a24ab73f11f2560a1fdbd9";
    hash = "sha256-VF/6HQmAM4OJ+nHUSrrWW8HQM7Pa1qr9X4vgoL8cyNo=";
  };
in {
  imports = [
    inputs.dankMaterialShell.homeModules.dank-material-shell

    ./niri
    ./default-apps.nix
  ];

  config = {
    # Complete desktop shell for Wayland compositors e.g. niri/hyprland
    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      plugins = {
        calculator = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "rochacbruno";
            repo = "DankCalculator";
            rev = "2f08bd47d8cb0caec7496aebc70b0b65c52e943b";
            sha256 = "sha256-3f5PkLmMWIgOxJHs+D1hcURU/TF0m7iQoYkmxMHg5WM=";
          };
        };
        dankPomodoroTimer = {
          enable = true;
          src = "${dmsPlugins}/DankPomodoroTimer";
        };
        emojiLauncher = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "devnullvoid";
            repo = "dms-emoji-launcher";
            rev = "9bbc5c0b0c41977dcdbacc49ae63c6d8b8670536";
            sha256 = "sha256-HGvpvMmg1Y5EB+tO2qeytsis1SSNWHuNPNHNEGSLtok=";
          };
        };
        niriWindows = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "rochacbruno";
            repo = "DankNiriWindows";
            rev = "b866af4cb599e7eeae90779b959f56b1a9905f18";
            sha256 = "sha256-KkB+xq4AObTqTDxtBVqfCsnxn0jnNk3iM4vpk9jlEBA=";
          };
        };
        nixMonitor = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "antonjah";
            repo = "nix-monitor";
            rev = "v1.0.3";
            sha256 = "sha256-biRc7ESKzPK5Ueus1xjVT8OXCHar3+Qi+Osv/++A+Ls=";
          };
        };
      };
    };

    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.config.common.default = ["gnome" "gtk"];
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      gnome-keyring
    ];

    home.packages = with pkgs; [
      qimgv # quick image viewer

      wl-clipboard # wl-copy and wl-paste

      gcr # Gnome Keyring system prompter
    ];
  };
}
