{inputs, ...}: {
  imports = [
    inputs.self.homeModules.home-shared
    inputs.self.homeModules.sequence
  ];

  usesDeterminateNix = true;

  # Use the 1Password SSH agent for keys managed by 1Password.
  programs.ssh.settings."*".IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
}
