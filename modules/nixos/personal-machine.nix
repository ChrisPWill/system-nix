{...}: {
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  networking.firewall.allowedTCPPorts = [
    # Spotify syncing tracks with mobile devices
    57621
  ];

  networking.firewall.allowedUDPPorts = [
    # Spotify discovery of Google Cast + Spotify Connect
    5353
  ];
}
