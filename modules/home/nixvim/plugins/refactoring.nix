{...}: {
  programs.nixvim = {
    # Reactoring based on Martin Fowler's book
    plugins.refactoring = {
      enable = true;
      enableTelescope = true;
    };

    plugins.which-key = {
      settings = {
        spec = [
          {
            __unkeyed-1 = "<leader>r";
            group = "refactoring";
          }
        ];
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>rr";
        action.__raw =
          /*
          lua
          */
          ''
            require("telescope").extensions.refactoring.refactors
          '';
        options.desc = "Select refactor";
      }
      {
        mode = "n";
        key = "<leader>re";
        action = ":Refactor extract_var ";
        options.desc = "Extract to variable";
      }
      {
        mode = "n";
        key = "<leader>rE";
        action = ":Refactor extract ";
        options.desc = "Extract to function";
      }
      {
        mode = "n";
        key = "<leader>rb";
        action = ":Refactor extract_block ";
        options.desc = "Extract to block";
      }
      {
        mode = "n";
        key = "<leader>ri";
        action = ":Refactor inline_var ";
        options.desc = "Inline variable";
      }
      {
        mode = "n";
        key = "<leader>rI";
        action = ":Refactor inline_func ";
        options.desc = "Inline function";
      }
    ];
  };
}
