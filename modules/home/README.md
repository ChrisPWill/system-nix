# Home Configuration Architecture

This directory implements a **Domain-Driven Design (DDD)** approach to Home Manager configuration.

## Philosophy

### 1. Intent over Syntax
Configuration is organized by the user's **intent**—what they are trying to achieve—rather than Nix-specific implementation details. Whether a tool is installed via a simple package list or a complex program module, it is grouped with other tools that serve the same functional purpose.

### 2. Compositional Orchestration
Each domain directory (e.g., `dev/`, `ops/`) contains a `default.nix` file. This file acts as an orchestrator, composing the various components within that domain. This keeps the top-level `home-shared.nix` clean and focused on high-level domain toggling.

### 3. Encapsulation
Tool-specific settings, plugins, and init scripts are encapsulated within their respective domain modules. This ensures that when a domain or tool is removed, its associated configuration logic is removed with it, preventing "configuration rot."

## Domain Definitions

- **[core/](./core)**: The fundamental identity of the system. Shells, fonts, and core Nix settings.
- **[dev/](./dev)**: The development environment. Editors, terminals, version control, and engineering utilities.
- **[ops/](./ops)**: Operational tools for system administration, process monitoring, and filesystem management.
- **[media/](./media)**: Tools for content consumption, information organization, and multimedia processing.
- **[desktop/](./desktop)**: The graphical environment, including window management and GUI applications.
- **[ai/](./ai)**: Integration of artificial intelligence services and local LLM orchestration.
