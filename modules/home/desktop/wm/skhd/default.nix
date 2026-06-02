{
  config,
  lib,
  pkgs,
  ...
}: let
  workspaces =
    (map (workspace: {
        key = workspace;
        name = workspace;
      })
      ["1" "2" "3" "4" "5" "6" "7" "8" "9"])
    ++ [
      {
        key = "q";
        name = "Q";
      }
      {
        key = "w";
        name = "W";
      }
      {
        key = "e";
        name = "E";
      }
      {
        key = "a";
        name = "A";
      }
      {
        key = "s";
        name = "S";
      }
      {
        key = "d";
        name = "D";
      }
    ];

  commandPath = lib.concatStringsSep ":" [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "$PATH"
  ];
  run = command: "PATH=${commandPath} ${command}";
  omni = command: run "omniwmctl command ${command}";
  script = name: lib.escapeShellArg "${config.homeModuleDir}/scripts/${name}";
  osascript = expression: run "osascript -e ${lib.escapeShellArg expression}";

  workspaceBindings =
    lib.concatMapStringsSep "\n" (workspace: "cmd + alt - ${workspace.key} : ${omni "switch-workspace ${workspace.name}"}")
    workspaces;

  moveWorkspaceBindings =
    lib.concatMapStringsSep "\n" (workspace: "cmd + alt + shift - ${workspace.key} : ${omni "move-to-workspace ${workspace.name}"}")
    workspaces;
in {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    services.skhd = {
      enable = true;
      errorLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.err.log";
      outLogFile = "${config.home.homeDirectory}/Library/Logs/skhd.out.log";

      config = ''
        # Top-level actions
        cmd + alt - t : ${run "${script "open-terminal-at-cwd"}"}
        cmd + alt - 0x2A : ${run "${script "toggle-pinned"} logseq logseq Logseq"}
        cmd + alt - o : ${run "${script "toggle-pinned"} electron obsidian Obsidian"}

        # Window focus
        cmd + alt - h : ${omni "focus left"}
        cmd + alt - j : ${omni "focus down"}
        cmd + alt - k : ${omni "focus up"}
        cmd + alt - l : ${omni "focus right"}

        # Workspace focus
        ${workspaceBindings}

        # Window movement
        cmd + alt + shift - h : ${omni "move left"}
        cmd + alt + shift - j : ${omni "move down"}
        cmd + alt + shift - k : ${omni "move up"}
        cmd + alt + shift - l : ${omni "move right"}

        # Move windows to workspaces
        ${moveWorkspaceBindings}

        # Monitor movement
        cmd + alt + ctrl - h : ${omni "focus-monitor prev"}
        cmd + alt + ctrl - l : ${omni "focus-monitor next"}
        cmd + alt + shift + ctrl - h : ${omni "swap-workspace-with-monitor left"}
        cmd + alt + shift + ctrl - l : ${omni "swap-workspace-with-monitor right"}

        # Media and system controls
        fn - f10 : ${osascript "set volume output muted not (output muted of (get volume settings))"}
        fn - f11 : ${osascript "set volume output volume (output volume of (get volume settings) - 5)"}
        fn - f12 : ${osascript "set volume output volume (output volume of (get volume settings) + 5)"}
      '';
    };
  };
}
