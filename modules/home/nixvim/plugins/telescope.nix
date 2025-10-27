{...}: {
  programs.nixvim.plugins = {
    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
      };
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fr" = "live_grep";
        "<leader>fb" = "buffers";
        "<leader>ft" = "treesitter";
        "<leader>fgs" = "git_status";
        "<leader>fgb" = "git_branches";
        "<leader>fgcc" = "git_commits";
      };
    };
  };
}
