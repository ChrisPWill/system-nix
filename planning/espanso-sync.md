# Plan: Cross-Platform Espanso (Text Expansion)

**Objective:** Implement a declarative, cross-platform text expansion system to share snippets (email templates, CLI flags, emojis) between Linux and macOS.

## Core Requirements
- **Shared Snippets:** A single YAML file (or set of files) managed by Nix.
- **System Integration:** Espanso must run as a background service on both OSs.
- **Searchability:** Ensure the Espanso search bar (Alt+Space by default) is accessible and doesn't conflict with WM hotkeys.

## Proposed Architecture
1.  **Module:** `modules/home/ops/espanso.nix`
2.  **Logic:**
    - Use `services.espanso.enable = true`.
    - Handle the config directory difference:
        - Linux: `~/.config/espanso/`
        - macOS: `~/Library/Application Support/espanso/` (Nix-darwin/Home Manager handles this abstraction).
3.  **Snippets:** Store snippets in `modules/home/ops/espanso/snippets.yml`.

## Implementation Steps
1.  **Define Base Config:** Set up the standard Espanso configuration (toggle key, search bar).
2.  **Migrate Snippets:**
    - Create a starter set: `:email`, `:date`, `:shrug`.
    - Add Atlassian-specific work snippets (Jira links, PR templates) gated by `config.isAtlassianMachine`.
3.  **Cross-Platform Activation:** Ensure the service starts automatically on login via `systemd` (Linux) and `launchd` (macOS).

## Success Criteria
- Typing `:date` expands to the current date on both Linux and macOS.
- Snippets added to the Nix config are available on both machines after a rebuild.
