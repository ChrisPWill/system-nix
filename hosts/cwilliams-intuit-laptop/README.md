# cwilliams-intuit-laptop

An Intuit-managed MacBook. Admin rights need an IT request and every app needs
approval, command-line tools included. This host installs only the apps named
in `approved-apps.nix`; everything else in this repository is left out.

It runs in two stages:

1. **Now: standalone Home Manager.** Installing Nix needs admin rights once.
   After that, `sw` never needs sudo.
2. **Later: nix-darwin as well.** Once you have admin rights for it, nix-darwin
   manages the system (Homebrew, macOS settings, Kanata) through `sw-system`,
   which needs sudo. Home Manager stays separate, so `sw` still needs no sudo.

Both stages read the approved apps from `approved-apps.nix`.

## Before you start

- **Ask IT to approve Determinate Nix.** Also ask whether they use binary
  allow-listing (for example Santa). If they do, Nix-built tools may be blocked
  until approved.
- **Your macOS username is `cwilliams82`.** If IT changes it, rename
  `users/cwilliams82.nix` to match, and change `users.users.cwilliams82` and
  `primaryUser` in `darwin-configuration.nix`.

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

4. Open a new terminal so `nix` is on your `PATH`, then make builds trust
   Intuit's Zscaler certificate. This needs admin rights, once.

   Zscaler intercepts HTTPS. Determinate Nix already copies the keychain's
   certificates, Zscaler's included, into `/etc/nix/macos-keychain.crt`, but
   builds that download source code (such as Neovim plugins from GitHub)
   don't read it. Without this step they fail with
   `unable to get local issuer certificate`.

   First check that Determinate's file trusts github.com through Zscaler. This
   should print `Verify return code: 0 (ok)`:

   ```bash
   openssl s_client -connect github.com:443 -CAfile /etc/nix/macos-keychain.crt </dev/null 2>/dev/null | grep 'Verify return code'
   ```

   Then pass the file to builds and restart the Nix daemon:

   ```bash
   printf 'extra-experimental-features = configurable-impure-env\nimpure-env = NIX_SSL_CERT_FILE=/etc/nix/macos-keychain.crt\n' | sudo tee /etc/nix/nix.custom.conf
   sudo launchctl kickstart -k system/systems.determinate.nix-daemon
   ```

   The first command replaces `/etc/nix/nix.custom.conf`. Keep it to exactly
   those two lines: nix-darwin recognises them and can take the file over
   later.

5. Do the first switch:

   ```bash
   nix run --inputs-from . home-manager -- switch --flake .#cwilliams82@cwilliams-intuit-laptop
   ```

   After this switch, git, curl, gh, Python and Node in new terminals use the
   same certificate file.

6. Open a new terminal again, then convert the clone to Jujutsu:

   ```bash
   cd ~/.system-nix && jj git init --colocate
   ```

7. Create an SSH key and add it to GitHub:

   ```bash
   ssh-keygen -t ed25519
   gh auth login
   gh ssh-key add ~/.ssh/id_ed25519.pub
   ```

From now on, run `sw` to apply changes to your user setup.

WezTerm is installed to `~/Applications/Home Manager Apps`. Spotlight may not
find it there; open it from Finder the first time.

If Intuit replaces its Zscaler certificate, Determinate Nix updates
`/etc/nix/macos-keychain.crt` itself. If the certificate error comes back
anyway, run the `openssl` check in step 4 to see whether that file is out of
date.

## Adding an app once IT approves it

Add its name to `approved-apps.nix`, then run `sw`. The list starts with the
command-line tools, editors and WezTerm; remove any that IT doesn't approve.

There is one name per tool. The names you can use are in `gatedApps` in
`modules/shared/approved-apps.nix`, and a misspelt name stops the build with an
error. Plugins bundled into an app come with it: approving `neovim` brings its
plugins and the language servers it bundles. Standalone tools have their own
names, such as `nixd` for running the Nix language server outside Neovim. Some apps only install under nix-darwin, because they come from
Homebrew or run as system services: `cleanshot`, `ghostty`, `imageoptim`,
`kanata`, `raycast`, `scroll-reverser`, `t3code`, `vivaldi`, and the macOS
parts of `omniwm` and `skhd`. For those, run `sw-system` too.

When you add a tool to any module, gate it too: add its name to `gatedApps`
and wrap it in `config.appApproved.<name>`, or list it in
`config.filterApproved`. The `approved-apps` flake check fails if anything
installs on this laptop with nothing approved:

```bash
nix build .#checks.aarch64-darwin.approved-apps
```

Fonts, Stylix theme files and Home Manager itself are exempt.

## Moving to nix-darwin (stage 2)

The nix-darwin configuration is `darwin-configuration.nix`. It hasn't been
activated on a real machine yet, so expect to fix things on the first run.

What changes when you switch:

- `sw-system` switches the system and needs sudo. Run it only when you change
  `darwin-configuration.nix`, `modules/darwin/` or a nix-darwin app's approval.
  `sw` keeps switching Home Manager without sudo.
- nix-darwin installs Homebrew into `/opt/homebrew`. If IT already installed
  Homebrew, nix-homebrew takes over that installation. Homebrew cleanup is
  off for this host, so it won't remove anything IT installed.
- macOS settings from `modules/darwin/darwin-shared.nix` apply: Dock, Finder,
  key repeat, trackpad, Touch ID for sudo, and a UK keyboard layout. IT's
  device management may override some of them.
- nix-darwin takes over the certificate setting from step 4.

To switch:

1. Get admin rights approved.
2. Run the macOS bootstrap script, which uses sudo:

   ```bash
   ~/.system-nix/scripts/bootstrap-macos --host cwilliams-intuit-laptop
   ```

3. From then on, use `sw-system` for system changes and `sw` for everything
   else.

To add your keyboard and window-manager setup, approve `kanata`, `skhd` and
`omniwm` (and `raycast` if you want it). Then follow the macOS permissions step
in [INSTALLATION.md](../../INSTALLATION.md#4-grant-macos-permissions). Kanata
also needs the Karabiner system extension approved, which IT may block.

## Renaming this host

IT names the machine, so `sw` finds this config through
`dev.nix.flakeHostName` rather than the hostname. To rename the host, rename
this directory and update `dev.nix.flakeHostName` in `users/cwilliams82.nix`.
