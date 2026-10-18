#!/usr/bin/env bash
package_available(){
 case "$PKG_FAMILY" in
  debian) apt-cache show "$1" >/dev/null 2>&1;;
  fedora) dnf -q list --available "$1" >/dev/null 2>&1;;
  arch) pacman -Si "$1" >/dev/null 2>&1;;
  opensuse) zypper --non-interactive search --match-exact "$1" 2>/dev/null | grep -qi "$1";;
  *) return 1;;
 esac
}
download_file(){
 local url="$1" output="$2"
 if command -v curl >/dev/null 2>&1; then curl --fail --location --retry 2 --output "$output" "$url"
 elif command -v wget >/dev/null 2>&1; then wget --https-only -O "$output" "$url"
 else echo 'FieldKit needs curl or wget to download this installer.'; return 1; fi
}

install_special_tool(){
 local key="$1" tmp url rc mem_kb
 case "$key" in
  metasploit)
   [[ "$(uname -m)" == x86_64 ]] || { echo 'The official Linux installer currently targets x86_64 systems.'; return 1; }
   echo 'FYI: If Metasploit is already installed, cancel and check it first. Continuing may install or update a separate copy.'
   confirm 'Download and run the official Rapid7 Metasploit installer?' || return 1
   tmp="$(mktemp -d)" || return 1
   url='https://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run'
   if download_file "$url" "$tmp/metasploit-installer.run"; then
    chmod 700 "$tmp/metasploit-installer.run"
    echo 'Launching the official Rapid7 installer. Follow its prompts to finish setup.'
    if (cd "$tmp" && sudo ./metasploit-installer.run); then rc=0; else rc=$?; fi
   else rc=1; fi
   rm -rf "$tmp"
   (( rc == 0 )) || return 1
   command -v msfconsole >/dev/null 2>&1 || [[ -x /opt/metasploit-framework/bin/msfconsole ]] || { echo 'Installer exited, but msfconsole was not found. Check the installer output and install path.'; return 1; }
   ;;
  burpsuite)
   [[ "$(uname -m)" == x86_64 ]] || { echo 'This installer path is for x86_64 Linux. Use the official download page for other architectures.'; return 1; }
   echo 'FYI: If Burp Suite is already installed, cancel and check it first. Continuing may install another copy.'
   confirm 'Download and launch the official PortSwigger Burp Suite installer?' || return 1
   tmp="$(mktemp -d)" || return 1
   url='https://portswigger.net/burp/releases/download?product=community&type=Linux'
   if download_file "$url" "$tmp/burpsuite-installer.sh"; then
    chmod 700 "$tmp/burpsuite-installer.sh"
    echo 'Launching the PortSwigger installer. Select Community Edition when prompted.'
    if (cd "$tmp" && ./burpsuite-installer.sh); then rc=0; else rc=$?; fi
   else rc=1; fi
   rm -rf "$tmp"
   (( rc == 0 )) || return 1
   command -v burpsuite >/dev/null 2>&1 || [[ -x /opt/BurpSuiteCommunity/BurpSuiteCommunity ]] || [[ -x "$HOME/BurpSuiteCommunity/BurpSuiteCommunity" ]] || { echo 'Installer exited, but FieldKit could not find a common Burp launch path. Check the installer destination.'; return 1; }
   ;;
  proton-vpn)
   [[ "$PKG_FAMILY" == debian ]] || { echo 'The automated Proton VPN installer is currently implemented for Debian/Ubuntu. See official instructions for other families.'; return 1; }
   echo 'FYI: If Proton VPN is already installed, cancel and check it first. This adds the official Proton repository and installs its GUI package.'
   confirm 'Download, verify, and install the official Proton VPN repository package?' || return 1
   tmp="$(mktemp -d)" || return 1
   url='https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb'
   if download_file "$url" "$tmp/protonvpn-stable-release.deb" && \
      printf '%s  %s\n' '0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180' "$tmp/protonvpn-stable-release.deb" | sha256sum --check --status; then
    if sudo dpkg -i "$tmp/protonvpn-stable-release.deb" && sudo apt-get update && sudo apt-get install -y proton-vpn-gnome-desktop; then rc=0; else rc=$?; fi
   else
    echo 'Download or SHA-256 verification failed. No repository package was installed.'; rc=1
   fi
   rm -rf "$tmp"
   (( rc == 0 )) || return 1
   command -v protonvpn-app >/dev/null 2>&1 || dpkg-query -W -f='${Status}' proton-vpn-gnome-desktop 2>/dev/null | grep -q 'install ok installed' || { echo 'Package install finished, but the expected Proton VPN package could not be verified.'; return 1; }
   echo 'Note: Proton officially supports GNOME; on Lubuntu/LXQt some tray/network integration may need extra configuration.'
   ;;
  bloodhound)
   echo 'BloodHound Community Edition requires a container runtime and has an official minimum of 8 GB RAM; this desktop has about 5.7 GiB.'
   echo 'Docker was removed from the FieldKit tool catalogue as requested. FieldKit will not install Docker as a hidden dependency.'
   echo 'If you want BloodHound CE, install/configure Docker separately, then follow the official BloodHound CLI setup.'
   echo 'Official instructions: https://bloodhound.specterops.io/get-started/quickstart/community-edition-installation'
   return 1
   ;;
  *) echo "No special installer is defined for $key"; return 1;;
 esac
}

install_tool(){
 local key="$1" package command method label purpose first docs rc=1
 package="$(get_field "$key" 3)"; command="$(get_field "$key" 4)"; method="$(get_field "$key" 5)"
 label="$(tool_name "$key")"; purpose="$(get_field "$key" 6)"; first="$(get_field "$key" 7)"; docs="$(get_field "$key" 8)"
 if [[ "$method" == installer ]]; then
  install_special_tool "$key" || { log WARN "Special installer failed or cancelled: $key"; return 1; }
  printf '\n✓ Verified: %s\nWhat it does: %s\nFirst step: %s\nDocs: %s\n' "$label" "$purpose" "$first" "$docs"
  log INFO "Verified special install: $key"
  return 0
 fi
 if [[ "$method" == upstream || "$method" == manual ]]; then
  printf '\n%s requires manual setup in this release.\nOfficial instructions: %s\n' "$label" "$docs"
  log INFO "Showed manual install guidance: $key"; return 1
 fi
 if [[ -z "$package" ]]; then echo 'No package mapping configured.'; return 1; fi
 if ! package_available "$package"; then
  echo "Package '$package' not found in configured $PKG_FAMILY repositories."
  echo "Check official docs: $docs"; log WARN "Package unavailable: $package"; return 1
 fi
 echo "Package: $package | Backend: $PKG_FAMILY"
 if [[ "${FIELDKIT_BATCH_CONFIRMED:-0}" != 1 ]]; then confirm "Install with administrator privileges?" || { log INFO "Cancelled install $package"; return 1; }; fi
 case "$PKG_FAMILY" in
  debian) sudo apt-get update && sudo apt-get install -y "$package" && rc=0;;
  fedora) sudo dnf install -y "$package" && rc=0;;
  arch) sudo pacman -S --needed --noconfirm "$package" && rc=0;;
  opensuse) sudo zypper --non-interactive install "$package" && rc=0;;
 esac
 if (( rc == 0 )) && { command -v "$command" >/dev/null 2>&1 || package_installed "$package"; }; then
  printf '\n✓ Verified: %s\nWhat it does: %s\nFirst step: %s\nDocs: %s\n' "$label" "$purpose" "$first" "$docs"
  log INFO "Verified install $package"
 else echo 'Installation or verification failed; review package-manager output.'; log ERROR "Install verification failed $package"; return 1; fi
}
