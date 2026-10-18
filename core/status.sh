#!/usr/bin/env bash
package_installed(){
 local name="$1"
 case "$PKG_FAMILY" in
  debian) dpkg-query -W -f='${Status}' "$name" 2>/dev/null | grep -q 'install ok installed';;
  fedora|opensuse) rpm -q "$name" >/dev/null 2>&1;;
  arch) pacman -Q "$name" >/dev/null 2>&1;;
  *) return 1;;
 esac
}
any_package_installed(){
 local name
 for name in "$@"; do
  if package_installed "$name"; then return 0; fi
 done
 return 1
}
known_install_path(){
 case "$1" in
  metasploit) [[ -x /opt/metasploit-framework/bin/msfconsole || -x /usr/local/bin/msfconsole || -x /usr/bin/msfconsole || -x "$HOME/.local/bin/msfconsole" ]] || any_package_installed metasploit-framework metasploit-framework-core ;;
  burpsuite) [[ -x /opt/BurpSuiteCommunity/BurpSuiteCommunity || -x /opt/BurpSuiteCommunity/burpsuite || -x /usr/local/bin/burpsuite || -x "$HOME/BurpSuiteCommunity/BurpSuiteCommunity" || -x "$HOME/.local/bin/burpsuite" ]] || any_package_installed burpsuite burpsuite-community ;;
  bloodhound) [[ -x /opt/BloodHound/BloodHound || -x /opt/bloodhound/BloodHound || -x /usr/local/bin/bloodhound || -x "$HOME/.local/bin/bloodhound" ]] || any_package_installed bloodhound bloodhound-ce ;;
  proton-vpn) command -v protonvpn-app >/dev/null 2>&1 || command -v protonvpn-cli >/dev/null 2>&1 || command -v protonvpn >/dev/null 2>&1 || any_package_installed proton-vpn-gnome-desktop protonvpn-cli protonvpn-gui proton-vpn-cli ;;
  firefox-standalone) [[ -x "$HOME/.local/opt/firefox/firefox" || -x "$HOME/Applications/firefox/firefox" || -x /opt/firefox/firefox || -x /usr/local/firefox/firefox ]];;
  *) return 1;;
 esac
}
tool_status(){
 local key="$1" package command method
 package="$(get_field "$key" 3)"; command="$(get_field "$key" 4)"; method="$(get_field "$key" 5)"
 if [[ "$method" == upstream || "$method" == manual || "$method" == installer ]]; then
  if command -v "$command" >/dev/null 2>&1 || known_install_path "$key"; then echo '✓ Installed'; else echo '? Unknown'; fi
 elif command -v "$command" >/dev/null 2>&1; then echo '✓ Installed'
 elif [[ -n "$package" ]] && package_installed "$package"; then echo '✓ Installed'
 elif [[ -z "$package" ]]; then echo '? Unknown'
 else echo '○ Not installed'; fi
}
