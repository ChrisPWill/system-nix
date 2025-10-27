{...}: {
  keymap = key: action: desc: {
    mode ? "n",
    noremap ? true,
    silent ? true,
  }: {
    inherit key action mode;
    options = {
      inherit noremap silent desc;
    };
  };
  keymapRaw = key: action: desc: {
    mode ? "n",
    noremap ? true,
    silent ? true,
  }: {
    inherit key mode;
    action.__raw = action;
    options = {
      inherit noremap silent desc;
    };
  };
}
