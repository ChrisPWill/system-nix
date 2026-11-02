# cwilliams-intuit-laptop

An Intuit-managed MacBook. Admin rights need an IT request and each app needs
approval, so this host installs only local command-line tools, WezTerm and
fonts until you approve more.

It runs in two stages:

1. **Now: standalone Home Manager.** Installing Nix needs admin rights once.
   After that, switching never needs sudo.
2. **Later: nix-darwin.** Once you have admin rights for it, nix-darwin manages
   the system too (Homebrew, macOS settings, Kanata). Every switch then needs
   sudo.

Both stages use the same `users/cwilliams.nix`, so the app list carries over.

## Before you start

- **Ask IT to approve Determinate Nix.** Also ask whether they use binary
  allow-listing (for example Santa). If they do, Nix-built tools may be blocked
  until approved.
- **Check your macOS username.** This config assumes `cwilliams`. If yours is
  different, rename `users/cwilliams.nix` to match, and change
  `users.users.cwilliams` and `primaryUser` in `darwin-configuration.nix`.
- **Set your email.** Replace `REPLACE-ME@intuit.com` in `users/cwilliams.nix`.
  Until you do, every build warns, and git commits use the placeholder.

## Install (stage 1: standalone Home Manager)

1. Install Apple's command-line tools, which provide `git`:

   ```bash
   xcode-select --install
   ```

2. Clone this repository:

   ```bash
   git clone https://github.com/ChrisPWill/system-nix.git ~/.system-nix
   ```

3. Install Determinate Nix. This is the step that needs admin rights. Use the
   macOS package from <https://docs.determinate.systems/>, or:

   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

4. Open a new terminal so `nix` is on your `PATH`, then do the first switch:

   ```bash
   cd ~/.system-nix
   nix run --inputs-from . home-manager -- switch --flake .#cwilliams@cwilliams-intuit-laptop
   ```

5. Open a new terminal again, then convert the clone to Jujutsu:

   ```bash
   cd ~/.system-nix && jj git init --colocate
   ```

6. Create an SSH key and add it to GitHub:

   ```bash
   ssh-keygen -t ed25519
   gh auth login
   gh ssh-key add ~/.ssh/id_ed25519.pub
   ```

From now on, run `sw` to apply changes. It notices that nix-darwin isn't
installed and switches Home Manager instead.

WezTerm is installed to `~/Applications/Home Manager Apps`. Spotlight may not
find it there; open it from Finder the first time.

## Adding an app once IT approves it

Add its name to `approvedApps` in `users/cwilliams.nix`, then run `sw`:

```nix
approvedApps = ["spotify"];
```

The names you can use are in `gatedApps` in `modules/home/home-shared.nix`.
A misspelt name stops the build with an error. Some apps only install under
nix-darwin, because they come from Homebrew or run as system services:
`cleanshot`, `ghostty`, `imageoptim`, `kanata`, `raycast`, `scroll-reverser`,
`t3code`, `vivaldi`, and the macOS parts of `omniwm` and `skhd`.

To gate a new app, add its name to `gatedApps` and wrap its module in
`config.appApproved.<name>`.

## Moving to nix-darwin (stage 2)

The nix-darwin configuration is `darwin-configuration.nix`. It hasn't been
activated on a real machine yet, so expect to fix things on the first run.

What changes when you switch:

- Every `sw` needs sudo.
- nix-darwin installs Homebrew into `/opt/homebrew`. If IT already installed
  Homebrew, nix-homebrew takes over that installation. Homebrew cleanup is
  off for this host, so it won't remove anything IT installed.
- macOS settings from `modules/darwin/darwin-shared.nix` apply: Dock, Finder,
  key repeat, trackpad, Touch ID for sudo, and a UK keyboard layout. IT's
  device management may override some of them.

To switch:

1. Get admin rights approved.
2. Run the macOS bootstrap script, which uses sudo:

   ```bash
   ~/.system-nix/scripts/bootstrap-macos --host cwilliams-intuit-laptop
   ```

   If Home Manager stops because an existing file is in the way, move that
   file aside and run the script again.

3. From then on, `sw` runs a nix-darwin switch.

To add your keyboard and window-manager setup, approve `kanata`, `skhd` and
`omniwm` (and `raycast` if you want it). Then follow the macOS permissions step
in [INSTALLATION.md](../../INSTALLATION.md#4-grant-macos-permissions). Kanata
also needs the Karabiner system extension approved, which IT may block.

## Renaming this host

IT names the machine, so `sw` finds this config through
`dev.nix.flakeHostName` rather than the hostname. To rename the host, rename
this directory and update `dev.nix.flakeHostName` in `users/cwilliams.nix`.
