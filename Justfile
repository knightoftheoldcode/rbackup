# Create directory structure and copy files over
# Execute systemd launchd etc to install 
# maybe have a few parameters for the justfile to replace certain things like backup interval, etc

# Locations:
# - rbackup.sh -> ~/.local/bin
# - dev.knightoftheoldcode.rbackup-hephaestus.plist -> ~/Library/LaunchAgents

# macOS (Darwin) - You can run as a service using launchd:
# launchctl load ~/Library/LaunchAgents/dev.knightoftheoldcode.rbackup-hephaestus.plist
# launchctl print gui/501/dev.knightoftheoldcode.rbackup-hephaestus.plist
# launchctl bootout gui/501/dev.knightoftheoldcode.rbackup-hephaestus.plist

# Future versions of this Justfile will take a configuration file (hostname, etc--or read straight from the system cli values)
# to build out the various files and stick them where they should go and run launchctl commands (or systemd, or whatever depending on your OS).
# For now, it's hardcoded to my username and hostname (which is best for security concerns in macOS). My DevLab NAS and linux home directories will be next.

# The script will create ~/.config/rbackup/ and store several files there during and between executions.
# You can manually `rm` the files ~/.config/rbackup/.backup_timestamp .maint_timestamp if you want to force either for the next run.
# I don't like the organization of the script but it's a first attempt and a sloppy backup is better than no backup.

