#!/bin/bash

# This is PROBABLY not neccessary or useful; this will always be an "online" install (no ISO as it's a util but I may want some of this for install.sh).
# Set install mode to online since boot.sh is used for curl installations
export RBACKUP_ONLINE_INSTALL=true

# ascii_art='#####    ##   ##### ##### #      ######  ####  #####   ##   ##### #  ####  #    #
# #    #  #  #    #     #   #      #      #        #    #  #    #   # #    # ##   #
# #####  #    #   #     #   #      #####   ####    #   #    #   #   # #    # # #  #
# #    # ######   #     #   #      #           #   #   ######   #   # #    # #  # #
# #    # #    #   #     #   #      #      #    #   #   #    #   #   # #    # #   ##
# #####  #    #   #     #   ###### ######  ####    #   #    #   #   #  ####  #    #'

ascii_art='rbackup'

clear
echo -e "\n$ascii_art\n"

# sudo pacman -Syu --noconfirm --needed git

# Use custom repo if specified, otherwise default to knightoftheoldcode/rbackup
RBACKUP_REPO="${RBACKUP_REPO:-knightoftheoldcode/rbackup}"

echo -e "\nCopying rbackup from: development_directory"
rm -rf ~/.local/share/rbackup
cp -R . ~/.local/share/rbackup

# echo -e "\nCloning rbackup from: https://github.com/${RBACKUP_REPO}.git"
# rm -rf ~/.local/share/rbackup/
# git clone "https://github.com/${RBACKUP_REPO}.git" ~/.local/share/rbackup >/dev/null

# # Use custom branch if instructed, otherwise default to main
# RBACKUP_REF="${RBACKUP_REF:-main}"
# if [[ $RBACKUP_REF != "main" ]]; then
  # echo -e "\e[32mUsing branch: $RBACKUP_REF\e[0m"
  # cd ~/.local/share/rbackup
  # git fetch origin "${RBACKUP_REF}" && git checkout "${RBACKUP_REF}"
  # cd -
# fi

echo -e "\nInstallation starting..."
source ~/.local/share/rbackup/install.sh
