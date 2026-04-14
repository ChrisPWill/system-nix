# Secret Management with sops-nix

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets.

- **Encrypted files** (e.g., `secrets/secrets.yaml`) **SHOULD** be committed to Git.
- **Private keys** (e.g., `~/.config/sops/age/keys.txt`) **MUST NEVER** be committed.

## Quick Start

### 1. Requirements

The following tools are installed via `modules/home/ops/sops.nix`:

- `sops`: The CLI tool for editing secrets.
- `age`: The encryption backend.
- `ssh-to-age`: Utility to convert SSH keys to age keys.

### 2. Encryption Keys

We use **age** keys for encryption:

- **User Key**: Located at `~/.config/sops/age/keys.txt`. Used for manual editing and Home Manager secrets.
- **Host Key**: Derived from `/etc/ssh/ssh_host_ed25519_key`. Used by NixOS for system-level secrets.

The public keys for both are configured in the root `.sops.yaml`.

## Common Workflows

### Manual Secret Editing

To edit secrets, `sops` needs to know where your private age key is. You can export this in your shell:

```bash
export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
sops secrets/secrets.yaml
```

### Adding a New Secret

1. Run `sops secrets/secrets.yaml` and add a new key-value pair.
2. Reference the secret in your Nix configuration:

#### In NixOS (`modules/nixos/ops/sops.nix`):

```nix
sops.secrets.my_secret = {
  owner = "cwilliams";
};
```

Access via: `config.sops.secrets.my_secret.path` (resolves to `/run/secrets/my_secret`).

#### In Home Manager (`modules/home/ops/sops.nix`):

```nix
sops.secrets.my_home_secret = {};
```

Access via: `config.sops.secrets.my_home_secret.path` (resolves to `/run/user/1000/secrets/my_home_secret`).

### Setting Up a New Machine (Host)

1. **Get the Host Age Key**:
   ```bash
   sudo ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```
2. **Update `.sops.yaml`**: Add the new host key to the `keys` and `creation_rules` sections.
3. **Re-encrypt**:
   ```bash
   sops updatekeys secrets/secrets.yaml
   ```

### Bootstrapping your User Key on a New Machine

If you have your SSH key but not the age `keys.txt` file:

```bash
mkdir -p ~/.config/sops/age
# If your SSH key is passphrase protected, you must use the private key and enter the pass:
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

## Troubleshooting

### "Could not decrypt"

- Verify your local private key matches the public key in `.sops.yaml`:
  ```bash
  age-keygen -y ~/.config/sops/age/keys.txt
  ```
- Ensure the `SOPS_AGE_KEY_FILE` environment variable is set if using the CLI manually.

### Permission Denied on `/run/secrets`

- System secrets are owned by `root:root` with `0400` permissions by default.
- Use `owner = "cwilliams";` in the secret definition to allow your user to read it.

## Practical Examples

### 1. Injecting Secrets into a Systemd Service (NixOS)

This is the most secure way to use secrets in services.

```nix
sops.secrets.api_key = {};

systemd.services.my-service = {
  serviceConfig = {
    # sops-nix creates a file in /run/secrets/api_key
    # EnvironmentFile reads it as "KEY=VALUE"
    EnvironmentFile = config.sops.secrets.api_key.path;
    ExecStart = "${pkgs.my-app}/bin/my-app";
  };
};
```

### 2. Using Secrets in your Shell (Zsh/Nushell)

Since secrets are only available at runtime, you can source them in your shell configuration.

**In Home Manager (`modules/home/ops/sops.nix`):**

```nix
sops.secrets.github_token = {};

programs.zsh.initExtra = ''
  # Source the secret if it exists
  if [ -f ${config.sops.secrets.github_token.path} ]; then
    export GITHUB_TOKEN=$(cat ${config.sops.secrets.github_token.path})
  fi
'';
```

### 3. Using Sops Templates (Advanced)

If you need to generate a config file that combines multiple secrets:

```nix
sops.templates."config.env".content = ''
  DATABASE_URL=postgres://user:${config.sops.placeholder.db_password}@localhost/db
  API_KEY=${config.sops.placeholder.api_key}
'';

# The resulting file is at /run/secrets-render/config.env
```
