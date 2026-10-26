#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND="$ROOT/install/backend.sh"
grep -q 'metasploit-framework-wrappers/msfupdate.erb' "$BACKEND" || { echo 'FAIL: Framework setup URL missing'; exit 1; }
if grep -q 'metasploit-latest-linux-x64-installer.run' "$BACKEND"; then
  echo 'FAIL: Metasploit Pro installer URL still present'
  exit 1
fi
grep -q 'Metasploit Framework (CLI), NOT the Metasploit Pro' "$BACKEND" || { echo 'FAIL: Framework/Pro distinction missing'; exit 1; }
echo 'PASS: Metasploit uses Framework package setup, not the Pro installer'
