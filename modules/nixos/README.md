The NixOS modules here are separated into three modules:

# host-shared.nix

host-shared is included in any host, it's really a bit of a hack as
it includes settings that can be set across both NixOS and nix-darwin.

# nixos-shared.nix

This includes settings that I set across any NixOS host, graphical or
non-graphical. This means it could in theory be applicable to a NixOS WSL
host or a headless box.

# graphical-environment.nix

This includes the typical settings I'd want on a desktop. Not set in
stone as of writing this, but should include things like:

* Desktop environment
* Audio settings not specific to a host
* Globally installed software
