# Home Configuration Architecture

This directory implements a **Domain-Driven Design (DDD)** approach to Home Manager configuration.

## Philosophy

### 1. Intent over Syntax
Configuration is organized by the user's **intent**—what they are trying to achieve—rather than Nix-specific implementation details. Whether a tool is installed via a simple package list or a complex program module, it is grouped with other tools that serve the same functional purpose.

### 2. Compositional Orchestration
Each domain directory contains an entry point (usually `default.nix`) that acts as an orchestrator, composing the various components within that domain. This keeps the top-level configuration clean and focused on high-level domain toggling.

### 3. Encapsulation
Tool-specific settings, plugins, and init scripts are encapsulated within their respective domain modules. This ensures that configuration logic remains localized and that removing a tool or domain cleans up all associated logic automatically.

## Domain Definitions

- **[core/](./core)**: The foundational shell environment, prompts, and system-wide font declarations.
- **[cli/](./cli)**: Modern enhancements to the standard Unix toolset, providing high-performance and feature-rich command-line utilities.
- **[dev/](./dev)**: The primary software engineering environment, including text editors, multiplexers, and version control systems.
- **[ops/](./ops)**: Operational utilities for system administration, process monitoring, and advanced filesystem manipulation.
- **[knowledge/](./knowledge)**: The "Second Brain" domain, focused on information ingestion, note-taking, and long-term knowledge organization.
- **[media/](./media)**: Digital signal processing and leisure-focused applications for multimedia manipulation and entertainment.
- **[desktop/](./desktop)**: The graphical interface layer, encompassing window management, terminal emulators, and standalone GUI applications.
- **[ai/](./ai)**: Integration and orchestration of artificial intelligence services and local machine learning models.
