# rbackup

Hourly home directory backups to Backblaze B2 with [restic](https://restic.net), scheduled and managed by [resticprofile](https://creativeprojects.github.io/resticprofile/). Works on macOS (launchd) and Linux (systemd); Windows is planned.

Part of the DevLab. Read more at [Knight of the Old Code](https://knightoftheoldcode.dev/projects/rbackup).

## How it works

- **One restic repo per install.** Each machine (or each OS on a dual-boot machine) backs up to its own prefix in one B2 bucket, with its own repo password and its own B2 application key scoped to that prefix. A leak on one machine never exposes another.
- **A fixed install ID**, not the live hostname, is restic's `--host`, the B2 prefix and the 1Password item name, so renaming a machine never orphans its snapshots.
- **Secrets live in 1Password.** Setup reads them once and writes `~/.config/rbackup/` (mode 700, files 600). Scheduled runs only read those files.
- **Schedules:** backup hourly (skipped on battery under 20%), forget + prune weekly, and a weekly check that reads back 1 GiB of data and then restores a canary file and compares it.
- **Alerting:** optional healthchecks.io pings on every backup (exit code only, never file paths), plus `rbackup doctor`.

## Layout

```
bin/rbackup             wrapper: doctor, restore-test, rotate-logs, or any resticprofile command
bin/rbackup-setup       one-time / idempotent setup for an install (macOS and Linux)
config/*.toml.tmpl      resticprofile config, rendered per machine by rbackup-setup
excludes/*.txt          restic exclude files: common.txt plus one per OS
```

## Setting up an install

Usually run by the OS setup repo (`setup-backup`), which installs the tools first.

1. **B2:** create a private bucket (encryption on), and an application key restricted to that bucket and the prefix `<install-id>/`.
2. **1Password:** create a Password item named `rbackup <install-id>` with fields:
   - `repository`: `s3:https://s3.<region>.backblazeb2.com/<bucket>/<install-id>`
   - `key-id`, `app-key`: the B2 application key
   - `password`: leave empty; setup generates it inside 1Password
   - `healthcheck-url` (optional): a healthchecks.io ping URL, period 1 day, grace 1 day

   The 1Password desktop app needs Settings > Developer > "Integrate with 1Password CLI" turned on.
3. **Run setup**, then take the first snapshot by hand, then run setup again to schedule:

   ```bash
   bin/rbackup-setup --id <install-id> --op-vault <vault>
   rbackup backup
   bin/rbackup-setup --id <install-id> --op-vault <vault>
   rbackup doctor
   ```

On macOS, give `/opt/homebrew/bin/resticprofile` (and `restic`) Full Disk Access in System Settings > Privacy & Security, or the scheduled jobs silently skip protected folders. `rbackup doctor` catches it through the canary restore.

## Everyday use

```bash
rbackup snapshots                  # list this install's snapshots
rbackup doctor                     # schedules, latest snapshot age, canary restore
rbackup restore latest --target /tmp/restore --include /Users/me/Documents/file.txt
rbackup mount ~/mnt                # browse snapshots (needs macFUSE / FUSE)
```

Never run `resticprofile --dry-run schedule`: it creates the real scheduled jobs.

## License

rbackup is released under the [MIT License](https://opensource.org/licenses/MIT).
