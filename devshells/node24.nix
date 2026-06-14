args @ {pkgs, ...}: import ../templates/node24/devshell.nix (args // {inherit pkgs;})
