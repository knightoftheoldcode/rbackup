#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define rbackup locations
export RBACKUP_PATH="$HOME/.local/share/rbackup"
export RBACKUP_INSTALL="$RBACKUP_PATH/install"
export RBACKUP_INSTALL_LOG_FILE="/var/log/rbackup-install.log"
export PATH="$RBACKUP_PATH/bin:$PATH"

# Show installation environment variables
gum log --level info "Installation Environment:"

env | grep -E "^(RBACKUP_CHROOT_INSTALL|RBACKUP_ONLINE_INSTALL|RBACKUP_USER_NAME|RBACKUP_USER_EMAIL|USER|HOME|RBACKUP_REPO|RBACKUP_REF|RBACKUP_PATH)=" | sort | while IFS= read -r var; do
  gum log --level info "  $var"
done

# Copy over rbackup configs
mkdir -p ~/.config
# cp -R ~/.local/share/rbackup/config/* ~/.config/
