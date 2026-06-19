# Dotfiles

## How to Use

Use command `stow .` in the dotfiles directory to create the symlinks in the parent (home) directory.

## Homebrew Bundle

### Dump installed packages to a Brewfile

```bash
brew bundle dump -f
```

`-f` overwrites an existing `Brewfile`.

### Install from a Brewfile

```bash
brew bundle install
```

## Secrets (SOPS + age)

Secrets are stored encrypted via [SOPS](https://github.com/getsops/sops) with [age](https://github.com/FiloSottile/age) as the encryption backend. The encrypted file (`.zsh_secrets.enc.env`) is safe to commit — it's AES-256-GCM ciphertext that can only be decrypted with the matching age private key.

### How it works

- `.sops.yaml` declares the age public key used for encryption (safe to commit)
- `.zsh_secrets.enc.env` contains the encrypted secrets (safe to commit)
- `~/.zshrc` decrypts and exports them as environment variables at shell startup

### Initial setup on a new machine

```bash
# 1. Install tools
brew install sops age

# 2. Generate an age keypair (first time only)
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
#    Copy the public key (age1...) into .sops.yaml

# 3. On subsequent machines, copy the private key instead
#    Transfer ~/.config/sops/age/keys.txt via AirDrop, USB, or scp

# 4. Stow the dotfiles
cd ~/.dotfiles && stow .

# 5. New shells will auto-decrypt secrets
```

### Adding or editing secrets

```bash
sops ~/.dotfiles/.zsh_secrets.enc.env
# Decrypts on the fly in $EDITOR — save and quit to re-encrypt
```

## Encrypted Config Files

Sensitive config files (SSH hosts, Git emails) are stored as `.enc` files in the repo and decrypted on demand. This keeps secrets out of plaintext while still being machine-reproducible.

### Files

| Encrypted source (committed) | Decrypted target (generated) |
| --- | --- |
| `.ssh/config.fraunhofer.enc` | `~/.ssh/config.fraunhofer` |
| `.gitconfig-fraunhofer.enc` | `~/.gitconfig-fraunhofer` |
| `.gitconfig-ventx.enc` | `~/.gitconfig-ventx` |

### How they're wired up

- `~/.ssh/config` uses `Include ~/.ssh/config.fraunhofer` to pull in SSH hosts
- `~/.gitconfig` uses `includeIf` to conditionally load the per-org email files

### Encrypting a new config file

```bash
sops -e --input-type binary .gitconfig-ventx > .gitconfig-ventx.enc
```

The `--input-type binary` flag is required for non-YAML/JSON files (plain text configs).

### Editing an encrypted file

```bash
sops .gitconfig-ventx.enc
# Opens decrypted in $EDITOR — save and quit to re-encrypt
```

### Generating the decrypted files

```bash
just decrypt
```

Decrypts all `.enc` config files and writes them to their target locations under `~/`. Run this once after cloning the repo on a new machine.
