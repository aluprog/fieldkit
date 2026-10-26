#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export FIELDKIT_ROOT="$ROOT"
source "$ROOT/core/common.sh"
source "$ROOT/core/os-detection.sh"
source "$ROOT/core/catalog.sh"
source "$ROOT/core/menus.sh"
source "$ROOT/install/backend.sh"
source "$ROOT/core/system.sh"
mkdir -p "$ROOT/logs"
detect_os
while true; do
  clear 2>/dev/null || true
  printf '=== FIELDKIT 0.4.1 ===\n\nOS: %s | Backend: %s\n\n' "$OS_PRETTY" "$PKG_FAMILY"
  printf '1) Install Tools\n2) Payloads & Scripts\n3) Documentation\n4) Study & Practice\n5) System & Updates\n\nQ) Quit\n'
  read -r -p 'Choose: ' c
  case "$c" in
    1) tools_menu ;;
    2) open_folder "$ROOT/payloads-scripts" ;;
    3) docs_menu ;;
    4) open_folder "$ROOT/study" ;;
    5) system_menu ;;
    q|Q) log INFO "Exit"; break ;;
    *) echo "Invalid choice"; pause ;;
  esac
done
