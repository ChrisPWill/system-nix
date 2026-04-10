{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      validateSopsFiles = false;

      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };

      secrets.example_secret = {
        # This will be decrypted to /run/secrets/example_secret by default.
        # It's good to specify owner/group if you need it accessible by a specific user.
        owner = "cwilliams";
      };
    };
  };
}
