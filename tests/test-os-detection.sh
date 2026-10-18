#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../core/os-detection.sh"
detect_os
[[ -n "$OS_ID" && -n "$OS_PRETTY" ]]
[[ "$PKG_FAMILY" =~ ^(debian|fedora|arch|opensuse|unsupported)$ ]]
echo "PASS: OS detection ($OS_PRETTY / $PKG_FAMILY)"
