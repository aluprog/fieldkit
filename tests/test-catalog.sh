#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/core/catalog.sh"
for key in nmap wireshark tcpdump dig whois metasploit setoolkit burpsuite sqlmap nikto gobuster zaproxy john hydra aircrack-ng bloodhound impacket python3 git firefox-standalone tor-browser proton-vpn keepassxc; do
  [[ -n "$(get_field "$key" 1)" ]] || { echo "FAIL: missing $key"; exit 1; }
done
for key in tshark traceroute venv curl wget jq shellcheck docker podman; do
  [[ -z "$(get_field "$key" 1)" ]] || { echo "FAIL: removed tool still present: $key"; exit 1; }
done
[[ "$(tool_name burpsuite)" == 'Burp Suite Community Edition' ]]
echo "PASS: catalogue entries, removals, and friendly names"
