{...}: {
  programs.nixvim.plugins = {
    mini = {
      enable = true;

      mockDevIcons = true;

      modules = {
        # Useful hotkeys for navigation see
        # https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
        bracketed = {};
        # Shows the current indent
        indentscope = {};
        # Add icons
        icons = {};
        # 'gcc' to comment line, 'gc' e.g. 'gcip' to comment inner paragraph
        comment = {};
        # Automatically adds matching brackets and removes them on backspace
        pairs = {};
        # Useful plugin (use gS) to split arguments over new lines
        splitjoin = {};
        # Makes trailing space visible
        trailspace = {};
      };
    };
  };
}
