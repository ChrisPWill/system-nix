{
  config,
  lib,
  ...
}: {
  programs.mise = lib.mkIf (config.isWorkMachine && config.appApproved.mise) {
    enable = true;

    globalConfig = {
      tools = {
        node = "latest";
        pnpm = "latest";
        # Without a global python, the mise `python3` shim falls through to
        # Apple's /usr/bin/python3 stub. Inside a nix shell (DEVELOPER_DIR set
        # to the nix apple-sdk) that stub runs nix's `xcrun python3`, which finds
        # the shim again and forks forever, flooding PerfPowerServices.
        # Matches the already-installed 3.14.x so nothing needs downloading.
        python = "3.14";
      };
      settings.idiomatic_version_file_enable_tools = ["node"];
    };
  };
}
