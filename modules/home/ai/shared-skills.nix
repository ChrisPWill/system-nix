{
  config,
  lib,
  ...
}: let
  cfg = config.home.ai;

  # The `programs.*.skills` options validate their source inside the build
  # sandbox, which cannot follow an out-of-store symlink. Linking each skill
  # directly keeps SKILL.md editable without a rebuild, the same way rules are
  # wired.
  skillNames = builtins.attrNames (builtins.readDir ./shared-skills);

  linkSkillsInto = dir:
    builtins.listToAttrs (map (name:
      lib.nameValuePair "${dir}/${name}" {
        source = config.lib.file.mkOutOfStoreSymlink "${config.homeModuleDir}/ai/shared-skills/${name}";
      })
    skillNames);
in {
  # Linking entry by entry rather than the whole directory leaves each agent's
  # skills/ as a real directory, so agent-installed skills can coexist.
  home.file =
    linkSkillsInto ".claude/skills"
    // lib.optionalAttrs (cfg.agentProvider == "codex") (linkSkillsInto ".codex/skills");
}
