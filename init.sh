#!/bin/bash

set -e

source ./lib/colors.sh

# Detect shell type
SHELL_NAME=$(basename "$SHELL")

# Decide which profile file to update
if [ "$SHELL_NAME" = "zsh" ]; then
  PROFILE_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    PROFILE_FILE="$HOME/.bash_profile"
  else
    PROFILE_FILE="$HOME/.bashrc"
  fi
else
  log_warn "Unknown shell ($SHELL_NAME). Defaulting to ~/.bashrc"
  PROFILE_FILE="$HOME/.bashrc"
fi

# Get the directory where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Path to bin folder (relative to the script)
BIN_DIR="$SCRIPT_DIR/bin"

# Add to profile file if not already present
if ! grep -q "export PATH=.*$BIN_DIR" "$PROFILE_FILE"; then
  echo -e "\n# Added by init.sh from $BIN_DIR" >> "$PROFILE_FILE"
  echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$PROFILE_FILE"
  log_success "Added $BIN_DIR to PATH in $PROFILE_FILE"
else
  log_info "$BIN_DIR already in PATH in $PROFILE_FILE"
fi

# Reload shell config
log_info "Reloading $PROFILE_FILE..."
# shellcheck disable=SC1090
source "$PROFILE_FILE"
