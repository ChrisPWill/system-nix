{inputs}: {
  nixPkgs.hostPlatform = "aarch64-darwin";

  users.users.cwilliams.home = /Users/cwilliams;

  system.stateVersion = 4;
}
