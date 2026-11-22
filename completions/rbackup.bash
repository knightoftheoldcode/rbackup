# bash completion for rbackup. rbackup-setup links this into
# ~/.local/share/bash-completion/completions/rbackup, where bash-completion
# loads it the first time `rbackup <Tab>` is pressed.

_rbackup() {
  local cur=${COMP_WORDS[COMP_CWORD]} prev=${COMP_WORDS[COMP_CWORD - 1]}
  local i w cmd=""

  # rbackup's own commands, then the resticprofile/restic ones it passes
  # through. Keep in step with bin/rbackup's header and completions/_rbackup.
  local own="doctor restore-test rotate-logs summary"
  local passthrough="snapshots backup restore mount ls find diff dump stats check forget prune unlock status schedule unschedule show"

  # bash splits "--color=auto" into "--color" "=" "auto" (= is in
  # COMP_WORDBREAKS), and readline replaces only the part after "=", so
  # offer bare values there.
  if [[ $cur == "=" && $prev == --color ]]; then
    mapfile -t COMPREPLY < <(compgen -W "auto always never")
    return
  fi
  if [[ $prev == "=" && ${COMP_WORDS[COMP_CWORD - 2]} == --color ]]; then
    mapfile -t COMPREPLY < <(compgen -W "auto always never" -- "$cur")
    return
  fi

  # The command is the first word that isn't part of --color=...
  for ((i = 1; i < COMP_CWORD; i++)); do
    w=${COMP_WORDS[i]}
    if [[ $w == --color || $w == "=" ]] || [[ ${COMP_WORDS[i - 1]} == "=" && ${COMP_WORDS[i - 2]} == --color ]]; then
      continue
    fi
    cmd=$w
    break
  done

  if [[ -z $cmd ]]; then
    if [[ $cur == -* ]]; then
      mapfile -t COMPREPLY < <(compgen -W "--color=" -- "$cur")
      compopt -o nospace 2>/dev/null
    else
      mapfile -t COMPREPLY < <(compgen -W "$own $passthrough" -- "$cur")
    fi
    return
  fi

  case $cmd in
    summary)
      [[ $prev == --count ]] && return # a number; nothing to offer
      local used=" ${COMP_WORDS[*]} " opts=""
      for w in backup check forget --count; do
        [[ $used == *" $w "* ]] || opts+=" $w"
      done
      mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
      ;;
    doctor | restore-test | rotate-logs) ;;
    *) mapfile -t COMPREPLY < <(compgen -f -- "$cur") ;;
  esac
}

complete -o default -F _rbackup rbackup
