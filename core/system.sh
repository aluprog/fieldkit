#!/usr/bin/env bash
system_menu(){
 while true; do
  echo '--- System & Updates ---'; echo '1) System information'; echo '2) Update system packages'; echo '3) Recent log'; echo; echo 'B) Back'
  read -r -p 'Choose: ' c
  case "$c" in
   1) printf '%s\n' "$OS_PRETTY"; uname -a; df -h "$HOME"; free -h; pause;;
   2) if confirm 'Update system packages? This changes the whole system'; then
       log INFO "System update requested"
       case "$PKG_FAMILY" in
        debian) sudo apt-get update && sudo apt-get upgrade;;
        fedora) sudo dnf upgrade;;
        arch) sudo pacman -Syu;;
        opensuse) sudo zypper refresh && sudo zypper update;;
        *) echo 'Unsupported backend';;
       esac
       log INFO "System update command finished"; pause
      fi;;
   3) tail -n 40 "$FIELDKIT_ROOT/logs/fieldkit.log"; pause;;
   b|B) return;;
   *) echo 'Invalid choice'; pause;;
  esac
 done
}
