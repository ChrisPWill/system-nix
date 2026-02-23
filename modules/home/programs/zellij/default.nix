# Terminal multiplexer
# https://zellij.dev
{config, ...}: {
  programs.zellij.enable = true;
  programs.zellij.settings = {
    default_layout = "compact";
    scroll_buffer_size = 10000;
    copy_on_select = true;
    pane_frames = false;
  };

  xdg.configFile."zellij/layouts" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/programs/zellij/layouts";
  };

  programs.zsh.shellAliases.zz = "f() { zellij attach -c ''\${1:-default} };f";
  programs.zsh.shellAliases.zr = "zellij run --";
  programs.zsh.shellAliases.zrf = "zellij run --floating --";
  programs.zsh.shellAliases.za = "f() { zellij attach ''\${1:-default} };f";
  programs.zsh.shellAliases.zl = "zellij list-sessions";
  programs.zsh.shellAliases.zk = "zellij kill-session";
  programs.zsh.shellAliases.zka = "zellij kill-all-sessions";
  programs.zsh.shellAliases.zd = "zellij delete-session";
  programs.zsh.shellAliases.zda = "zellij delete-all-sessions";
  programs.zsh.shellAliases.edit = "f() { if [[ -n \"$1\" ]]; then zellij attach \"$1\" || zellij -s \"$1\" -l dev else zellij -l dev fi };f";
  programs.nushell.shellAliases.zr = "zellij run --";
  programs.nushell.shellAliases.zrf = "zellij run --floating --";
  programs.nushell.shellAliases.zl = "zellij list-sessions";
  programs.nushell.shellAliases.zk = "zellij kill-session";
  programs.nushell.shellAliases.zka = "zellij kill-all-sessions";
  programs.nushell.shellAliases.zd = "zellij delete-session";
  programs.nushell.shellAliases.zda = "zellij delete-all-sessions";
  programs.nushell.extraConfig = ''
    def zz [name?: string] {
      let session = ($name | default "default")
      zellij attach -c $session
    }

    def za [name?: string] {
      let session = ($name | default "default")
      zellij attach $session
    }

    def edit [name?: string] {
      if ($name != null) {
        zellij -l dev attach -c $name
      } else {
        zellij -l dev
      }
    }
  '';
}
