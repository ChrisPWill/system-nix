args @ {
  perSystem,
  pkgs,
  ...
}:
((import ../lib args).languageTooling {inherit perSystem pkgs;}).mkShell {
  stacks = [
    "jvm"
    "python"
  ];
  extraPackages = with pkgs; [
    cloudflared
    google-cloud-sdk
    libpq
    libyaml
  ];
}
