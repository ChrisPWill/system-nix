{utils, ...}: {pkgs, ...}: let
  keymapRaw = utils.keymapRaw;
in {
  programs.nixvim = {
    plugins.dap-ui.enable = true;
    plugins.dap = {
      enable = true;

      configurations.javascript = [
        {
          name = "Attach to process";
          type = "js-debug";
          request = "attach";
          processId = "require('dap.utils').pick_process";
        }
      ];

      adapters.servers = {
        # js-debug = {
        #   host = "localhost";
        #   port = "\${port}";
        #   executable = {
        #     command = "${pkgs.nodejs}/bin/node";
        #     args = ["${pkgs.vscode-js-debug}/src/dapDebugServer.js" "\${port}"];
        #   };
        # };
      };
    };

    keymaps = [
      (keymapRaw "<leader>td" "require('dapui').toggle" "Toggle DAP-UI (debugger UI)" {})
    ];

    extraConfigLua = ''
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    '';

    extraPackages = with pkgs; [
      # vscode-js-debug
    ];
  };
}
