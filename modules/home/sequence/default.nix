{pkgs, ...}: {
  userEmail = "chris.williams@sequencehq.com";

  # Devenv management
  programs.mise.enable = true;
  # Github CLI
  programs.gh.enable = true;

  home.packages = with pkgs; [
    libpq # Postgres
    terragrunt # TF wrapper
    terraform
    google-cloud-sdk
    mkcert
    cloudflared
    uv
  ];
}
