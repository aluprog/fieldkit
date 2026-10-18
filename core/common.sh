#!/usr/bin/env bash
log(){ printf '%s [%s] %s\n' "$(date '+%F %T')" "$1" "$2" >> "$FIELDKIT_ROOT/logs/fieldkit.log"; }
pause(){ read -r -p $'\nPress Enter to continue...' _; }
confirm(){ local a; read -r -p "${1:-Continue?} [y/N] " a; [[ "$a" =~ ^([yY]|[yY][eE][sS])$ ]]; }
open_folder(){ mkdir -p "$1"; if command -v xdg-open >/dev/null; then xdg-open "$1" >/dev/null 2>&1 & else echo "Folder: $1"; pause; fi; }
