# Terminal multiplexer
# https://zellij.dev
{...}: {
  programs.zellij.enable = true;
  programs.zellij.settings = {
    scroll_buffer_size = 10000;
    copy_on_select = true;
    pane_frames = false;
  };
  programs.zsh.shellAliases.zz = "f() { zellij attach -c ''\${1:-default} };f";
  programs.zsh.shellAliases.zr = "zellij run --";
  programs.zsh.shellAliases.zrf = "zellij run --floating --";
  programs.zsh.shellAliases.za = "f() { zellij attach ''\${1:-default} };f";
  programs.zsh.shellAliases.zl = "zellij list-sessions";
  programs.zsh.shellAliases.zk = "zellij kill-session";
  programs.zsh.shellAliases.zka = "zellij kill-all-sessions";
  programs.nushell.shellAliases.zr = "zellij run --";
  programs.nushell.shellAliases.zrf = "zellij run --floating --";
  programs.nushell.shellAliases.zl = "zellij list-sessions";
  programs.nushell.shellAliases.zk = "zellij kill-session";
  programs.nushell.shellAliases.zka = "zellij kill-all-sessions";
  programs.nushell.extraConfig = ''
    def zz [name?: string] {
      let session = ($name | default "default")
      zellij attach -c $session
    }

    def za [name?: string] {
      let session = ($name | default "default")
      zellij attach $session
    }
  '';
}
