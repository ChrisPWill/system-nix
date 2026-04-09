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
    source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/dev/multiplexer/layouts";
  };

  programs.fish.functions.zz = ''
    if test -n "$argv[1]"
      zellij attach -c $argv[1]
    else
      zellij attach -c default
    end
  '';
  programs.fish.shellAliases.zr = "zellij run --";
  programs.fish.shellAliases.zrf = "zellij run --floating --";
  programs.fish.functions.za = ''
    if test -n "$argv[1]"
      zellij attach $argv[1]
    else
      zellij attach default
    end
  '';
  programs.fish.shellAliases.zl = "zellij list-sessions";
  programs.fish.shellAliases.zk = "zellij kill-session";
  programs.fish.shellAliases.zka = "zellij kill-all-sessions";
  programs.fish.shellAliases.zd = "zellij delete-session";
  programs.fish.shellAliases.zda = "zellij delete-all-sessions";
  programs.fish.functions.edit = ''
    # Grab the first argument, if it exists
    set -l session_name "$argv[1]"

    # If no argument was provided, try to get the repo-name
    if test -z "$session_name"
      set session_name (repo-name 2>/dev/null)
    end

    # If we now have a valid session_name (either from arg or repo-name)
    if test -n "$session_name"
      zellij -l dev attach -c "$session_name"
    else
      zellij -l dev
    end
  '';
  programs.zsh.shellAliases.zz = "f() { zellij attach -c ''\${1:-default} };f";
  programs.zsh.shellAliases.zr = "zellij run --";
  programs.zsh.shellAliases.zrf = "zellij run --floating --";
  programs.zsh.shellAliases.za = "f() { zellij attach ''\${1:-default} };f";
  programs.zsh.shellAliases.zl = "zellij list-sessions";
  programs.zsh.shellAliases.zk = "zellij kill-session";
  programs.zsh.shellAliases.zka = "zellij kill-all-sessions";
  programs.zsh.shellAliases.zd = "zellij delete-session";
  programs.zsh.shellAliases.zda = "zellij delete-all-sessions";
  programs.zsh.initContent = ''
    edit() {
      local session_name="$1"

      # If no argument was provided, try to get the repo-name
      if [[ -z "$session_name" ]]; then
        session_name="$(repo-name 2>/dev/null)"
      fi

      # If we have a valid session_name
      if [[ -n "$session_name" ]]; then
        zellij -l dev attach -c "$session_name"
      else
        zellij -l dev
      fi
    }
  '';
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
      let sessionName = if $name != null { $name } else { repo-name }

      if ($sessionName != null) {
        zellij -l dev attach -c $sessionName
      } else {
        zellij -l dev
      }
    }
  '';
}
