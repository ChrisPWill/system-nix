{
  perSystem,
  pkgs,
  ...
}:
import ./system-nix.nix {inherit perSystem pkgs;}
