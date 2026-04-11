# .system-nix

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![nix-darwin](https://img.shields.io/badge/nix--darwin-unstable-blue.svg?logo=apple&logoColor=white)](https://github.com/LnL7/nix-darwin)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-unstable-blue.svg?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

A **Domain-Driven** Nix system configuration managed with [numtide/blueprint](https://github.com/numtide/blueprint). This repository provides a unified, "Intent-over-Syntax" approach for NixOS, nix-darwin, and Home Manager across personal and work environments.

---

## 🧭 Quick Links

| Guide                                    | Description                                                  |
| :--------------------------------------- | :----------------------------------------------------------- |
| **[INSTALLATION.md](./INSTALLATION.md)** | Cloning, bootstrapping, and ISO-based installation.          |
| **[GEMINI.md](./GEMINI.md)**             | **Developer Guide:** Architectural mandates and conventions. |
| **[SECRETS.md](./SECRETS.md)**           | Guide for managing encrypted secrets with `sops-nix`.        |
| **[PERFORMANCE.md](./PERFORMANCE.md)**   | Instructions for profiling evaluation and system speed.      |

---

## 🏗️ Architecture: Intent Over Syntax

Following a **Domain-Driven Design (DDD)** approach, configuration is organized by the user's **intent**—what they are trying to achieve—rather than Nix-specific implementation details.

### 🌐 Functional Domains

- 🛠️ **[core/](./modules/home/core)**: Foundational shell, prompts, and fonts.
- 🐚 **[cli/](./modules/home/cli)**: Modern enhancements to the standard Unix toolset.
- 💻 **[dev/](./modules/home/dev)**: Engineering environment (Editors, VCS, Multiplexers).
- ⚙️ **[ops/](./modules/home/ops)**: System administration, monitoring, and sops.
- 🖥️ **[desktop/](./modules/home/desktop)**: Graphical interface, Niri WM, and Terminals.
- 🧠 **[knowledge/](./modules/home/knowledge)**: Note-taking and information organization.
- 🎬 **[media/](./modules/home/media)**: Multimedia processing and entertainment.
- 🤖 **[ai/](./modules/home/ai)**: Local LLMs (Ollama) and AI service orchestration.

---

## 🖥️ Machine Matrix

| Hostname                | OS        | Role                                               |
| :---------------------- | :-------- | :------------------------------------------------- |
| `cwilliams-laptop`      | **NixOS** | Primary Personal Machine (CachyOS kernel, Niri).   |
| `cwilliams-work-laptop` | **macOS** | Work Environment (nix-darwin).                     |
| `personal-pc-win`       | **WSL2**  | Standalone Home Manager on Windows.                |
| `installer`             | **ISO**   | Custom installation media with pre-baked settings. |

---

## ✨ Key Features

### ⌨️ Global Leader (Kanata/Niri)

The system implements a **Global Leader** capability using **Kanata** for hardware-level keyboard layers and **Niri** for window management.

- **Caps Lock** acts as the Leader: **Tap** for `Esc`, **Hold** for `Mod+Alt+Shift`.
- This enables consistent, mnemonic hotkeys across all environments.

### 🌓 Hybrid Development Philosophy

- **Neovim & Helix Parity:** Neovim (`meow`) uses Helix-inspired navigation (`g` prefix) and selection modes while retaining its native "Verb-Noun" model.
- **Unified Tooling:** Both editors share synchronized LSPs (nixd, ruff, etc.) and themes for zero-friction switching.

### 🏗️ Project Templates

Bootstrap new projects instantly using pre-configured flake templates:

```bash
# List available templates
nix flake show .#templates

# Initialize a new project
nix flake init -t .#rust-simple
```

### 🧰 Modern Workflows

- **[envoluntary](https://github.com/dfrankland/envoluntary):** A direnv-like matcher that avoids needing to create gitignored nix files in projects.
- **Jujutsu (`jj`):** The preferred VCS for this repository (supports git operations with a more powerful model).

---

## 🚀 Common Commands

| Alias       | Command                               | Description                           |
| :---------- | :------------------------------------ | :------------------------------------ |
| `hms`       | `home-manager switch --flake .`       | Rebuild Home Manager profile.         |
| `nrs`       | `sudo nixos-rebuild switch --flake .` | Rebuild NixOS (Linux).                |
| `drs`       | `darwin-rebuild switch --flake .`     | Rebuild nix-darwin (macOS).           |
| `nd <name>` | `nix develop .#<name>`                | Enter a devshell (e.g., `nd node24`). |

---

## 🤝 Contribution & Development

This repository uses [numtide/blueprint](https://github.com/numtide/blueprint), which automatically exports NixOS configurations, Home Manager profiles, and devshells based on the folder structure.

Please refer to **[GEMINI.md](./GEMINI.md)** for detailed contribution rules and architectural mandates before submitting changes.
