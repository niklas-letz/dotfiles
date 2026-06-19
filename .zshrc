# Enable Zsh autosuggestions and syntax highlighting
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable Starship prompt
eval "$(starship init zsh)"

# Initialize Zsh completion system
fpath=($HOME/.zsh_completions $fpath)
autoload -U compinit
compinit

# Set environment variables
export XDG_CONFIG_HOME="$HOME/.config"
export HOMEBREW_NO_ENV_HINTS=1
export PATH="$PATH:/Users/niklas/.lmstudio/bin"
export KIND_EXPERIMENTAL_PROVIDER=podman

# Set aliases
alias k=kubectl
alias ll="ls -lah"

# Decrypt and load secrets via SOPS
eval "$(sops -d ~/.zsh_secrets.enc.env 2>/dev/null)"
