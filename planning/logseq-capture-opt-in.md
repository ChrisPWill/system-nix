# Plan: LogSeq Capture Opt-In

**Objective:** Move `services.logseq-capture.enable` out of the universal knowledge domain default so only hosts or roles that actually need the capture service enable it.

## Core Requirements

- **No Universal Side Effect:** Importing `modules/home/knowledge` should install knowledge tools but should not start the capture bot by default.
- **Host/Role Ownership:** Hosts or role modules should explicitly opt into `services.logseq-capture.enable`.
- **Cross-Platform Support:** Preserve the existing Linux `systemd.user` and macOS `launchd` service behavior.
- **Secret Compatibility:** Preserve use of `config.sops.secrets.logseq_capture_tokens.path`.

## Proposed Architecture

1.  **Module Default:**
    - Keep `modules/home/knowledge/logseq-capture.nix` as the service definition.
    - Remove the unconditional enable from `modules/home/knowledge/default.nix`.
2.  **Enable Location:**
    - Enable the service in the host user config or a small role module, depending on how broadly it should apply.
    - Likely candidates:
      - Personal Linux laptop user config.
      - Work macOS user config if the capture bot is wanted there.
3.  **Optional Role:**
    - If multiple hosts need the service, add a small role module such as `modules/home/knowledge/capture-role.nix` or `modules/home/roles/logseq-capture.nix`.

## Implementation Steps

1.  Remove `services.logseq-capture.enable = true;` from `modules/home/knowledge/default.nix`.
2.  Add explicit enables to the relevant host user modules.
3.  Build the relevant system flake targets used by `nixos-rebuild` and `darwin-rebuild` to confirm the service is still included correctly on Linux and macOS.
4.  Update documentation to explain that LogSeq is installed by the knowledge domain, while the capture bot is opt-in.

## Success Criteria

- A host importing `home-shared` no longer starts LogSeq Capture unless it explicitly opts in.
- Hosts that opt in still get the correct `systemd.user` or `launchd` service.
- The relevant host build targets pass, for example `.#nixosConfigurations.cwilliams-laptop.config.system.build.toplevel` and `.#darwinConfigurations.cwilliams-work-laptop.system`.
