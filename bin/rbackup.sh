#!/bin/bash
set -euo pipefail

# TODO: create a GitHub repo OSS with MIT? license? (show how to fork and clone as a sample in my DevLab book)
# TODO: move into .restic directory in $HOME (is this wise?)
# TODO: extract environment variables (exports) to separate files per host (prep for multi-machine, also helps to source in case you want to work with it on the CLI)
# TODO: add loop for maintenance? (or do we let each host do its own maintenance? user preference ... never make a deal with the Preferences Daemon)
# TODO: perhaps we separate maint into forget and prune / check (do the prune and check way less frequently due to cost issues for API hits)
# TODO: ultimately wrap in macOS Console Application that controls the shell scripts so there's only one backup entry per mac (probably not a similar need for linux but maybe)
# TODO: better organize all of the restic stuff ... logs should be under dev.knightoftheoldcode/restic/backup /maint / etc (consider the logfile entry in Console app)
# TODO: extract all user specific items (such as wifi network names) into environment vars (maybe even into encrypted secrets?)
# TODO: consider using exit code 0 (OK) for the case where we fall through due to timestamp override (instead of 2 which is TECHNICALLY an error and shows in stuff like launchcontrol app)
# TODO: is it worth doing a restic check (without read-data on a more regular basis? if so we can prune more often and do a check without read-data, then just read-data check after the "online" maintenance script)

CONFIG_DIR=~/.config/rbackup
PID_FILE=$CONFIG_DIR/.pid
BACKUP_TIMESTAMP_FILE=$CONFIG_DIR/.backup_timestamp
MAINT_TIMESTAMP_FILE=$CONFIG_DIR/.maint_timestamp
RUN_BACKUP=true
RUN_MAINT=true

function set_pid {
  echo $$ > $PID_FILE
}

function clear_pid {
  rm $PID_FILE
}

if [[ ! -e $CONFIG_DIR ]]; then
    mkdir $CONFIG_DIR
elif [[ ! -d $CONFIG_DIR ]]; then
    echo "$CONFIG_DIR already exists but is not a directory" 1>&2
    exit 99
fi

if [ -f "$PID_FILE" ]; then
  if ps -p $(cat $PID_FILE) > /dev/null; then
	echo $(/bin/date +"%Y-%m-%d %T") "File $PID_FILE exists. The backup is likely in progress."
	exit 1
  else
	echo $(/bin/date +"%Y-%m-%d %T") "File $PID_FILE exists but process " $(cat $PID_FILE) " not found. Removing PID file."
	rm $PID_FILE
  fi
fi

# if [[ $(networksetup -getairportnetwork en0 | grep -E "Avenger\'s Tower|Work-Network") == "" ]]; then
#  echo $(/bin/date +"%Y-%m-%d %T") "Unsupported network."
#  exit 3
# fi

# if [[ $(pmset -g ps | head -1) =~ "Battery" ]]; then
#  echo $(date +"%Y-%m-%d %T") "Computer is not connected to the power source."
#  exit 4
# fi

set_pid

function export_env {
  export B2_ACCOUNT_ID=$(security find-generic-password -s restic-backup-b2-account-id -w)
  export B2_ACCOUNT_KEY=$(security find-generic-password -s restic-backup-b2-application-key -w)
  export RESTIC_HOST="$(hostname)"
  export RESTIC_PATH="$HOME"
  export RESTIC_REPOSITORY=$(security find-generic-password -s restic-backup-repository -w)
  export RESTIC_PASSWORD_COMMAND='security find-generic-password -s restic-backup-password-repository -w'
}

function restic_backup {
  export_env
  
  /Users/cvs/.asdf/shims/restic backup --verbose --compression max --exclude-caches --one-file-system --cleanup-cache \
    --exclude "$HOME/Applications" \
    --exclude "$HOME/Downloads" \
    --exclude "$HOME/Library" \
    --exclude "$HOME/snap" \
    --exclude "$HOME/.Trash" \
    --exclude "$HOME/.android" \
    --exclude "$HOME/.ansible" \
    --exclude "$HOME/.asdf" \
    --exclude "$HOME/.bundle" \
    --exclude "$HOME/.cache" \
    --exclude "$HOME/.dbus" \
    --exclude "$HOME/.dropbox" \
    --exclude "$HOME/.dropbox-dist" \
    --exclude "$HOME/.local/pipx" \
    --exclude "$HOME/.local/share/Trash" \
    --exclude "$HOME/.npm" \
    --exclude "$HOME/.pyenv" \
    --exclude "$HOME/.thumbnails" \
    --exclude "$HOME/.virtualenvs" \
    --exclude "node_modules" \
    --exclude ".tox" \
    "$RESTIC_PATH"
}

function rbackup {
  echo $(/bin/date +"%Y-%m-%d %T") "-- Backup Start --"
  
  restic_backup
  
  echo $(/bin/date +"%Y-%m-%d %T") "-- Backup Finished --"
  echo $(/bin/date -v +1H +"%s") > $BACKUP_TIMESTAMP_FILE
}

if [ -f "$BACKUP_TIMESTAMP_FILE" ]; then
  time_run=$(cat "$BACKUP_TIMESTAMP_FILE")
  current_time=$(date +"%s")
    
  if [ "$current_time" -lt "$time_run" ]; then
    RUN_BACKUP=false
  fi
fi

if [ "$RUN_BACKUP" == true ]; then
  rbackup
fi

function restic_forget {
  export_env

  /Users/cvs/.asdf/shims/restic forget \
        --host "$RESTIC_HOST" \
        --path "$RESTIC_PATH" \
        --tag '' \
        --keep-within-daily 7d \
        --keep-within-weekly 1m \
        --keep-within-monthly 1y \
        --keep-within-yearly 100y
}

function restic_prune {
  export_env

  /Users/cvs/.asdf/shims/restic prune
}

function restic_check {
  export_env

  /Users/cvs/.asdf/shims/restic check --read-data-subset=1G
}

function rmaint {
  echo $(/bin/date +"%Y-%m-%d %T") "-- Maintenance Start --"
  
  restic_forget
  restic_prune
  restic_check
  
  echo $(/bin/date +"%Y-%m-%d %T") "-- Maintenance Finished --"
  echo $(/bin/date -v +1w +"%s") > $MAINT_TIMESTAMP_FILE
}

if [ -f "$MAINT_TIMESTAMP_FILE" ]; then
  time_run=$(cat "$MAINT_TIMESTAMP_FILE")
  current_time=$(date +"%s")
    
  if [ "$current_time" -lt "$time_run" ]; then
    RUN_MAINT=false
  fi
fi

if [ "$RUN_MAINT" == true ]; then
  rmaint
fi

clear_pid
