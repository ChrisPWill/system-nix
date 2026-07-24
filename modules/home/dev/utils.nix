{pkgs, ...}: {
  home.packages = with pkgs; [
    # JSON formatting etc.
    jq
  ];
}
