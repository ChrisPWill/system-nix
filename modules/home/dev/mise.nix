{
  config,
  lib,
  ...
}: {
  programs.mise = lib.mkIf config.isWorkMachine {
    enable = true;

    globalConfig = {
      tools = {
        node = "latest";
        pnpm = "latest";
      };
      settings.idiomatic_version_file_enable_tools = ["node"];
    };
  };
}
