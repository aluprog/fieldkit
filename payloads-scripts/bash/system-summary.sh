#!/usr/bin/env bash
set -u
printf 'Host: %s\nKernel: %s\nArchitecture: %s\n' "$(hostname)" "$(uname -sr)" "$(uname -m)"
df -h "$HOME"
free -h
