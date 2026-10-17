
#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run FieldKit as your normal user, not with sudo."
    exit 1
fi

if [[ ! -r /etc/os-release ]]; then
    echo "Cannot identify this operating system."
    exit 1
fi

source /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "This version currently supports Ubuntu and Lubuntu."
    exit 1
fi

declare -A names=(
    [1]="Nmap"
    [2]="Wireshark"
    [3]="Python development tools"
    [4]="Git"
    [5]="curl and wget"
    [6]="Network utilities"
    [7]="System utilities"
    [8]="Packet capture tools"
    [9]="Web security tools"
    [10]="Gobuster directory scanner"
)

declare -A packages=(
    [1]="nmap"
    [2]="wireshark"
    [3]="python3 python3-venv python3-pip"
    [4]="git"
    [5]="curl wget"
    [6]="dnsutils net-tools traceroute whois"
    [7]="htop jq unzip p7zip-full"
    [8]="tcpdump tshark"
    [9]="sqlmap nikto"
    [10]="gobuster"
)

install_tools() {
    local selected=("$@")
    local pkgs=()
    local item
    local answer

    for item in "${selected[@]}"; do
        echo " - ${names[$item]}"
        read -r -a group <<< "${packages[$item]}"
        pkgs+=("${group[@]}")
    done

    echo
    echo "Packages: ${pkgs[*]}"
    read -r -p "Install these packages? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || return 0

    sudo apt update
    sudo apt install -y "${pkgs[@]}"

    echo "APT installation finished. Check for errors above."
}

install_firefox() {
    local archive_dir="$HOME/Downloads/FieldKit-archives"
    local install_dir="$HOME/Applications/firefox-fieldkit"
    local temp_dir

    if [[ "$(uname -m)" != "x86_64" ]]; then
        echo "This Firefox download option currently targets x86_64 PCs."
        return 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo "curl is required. Install it from the FieldKit menu first."
        return 1
    fi

    mkdir -p "$archive_dir" "$HOME/Applications"
    echo "Downloading Firefox from Mozilla's official download service..."

    if ! curl -fL --retry 3 \
        "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" \
        -o "$archive_dir/firefox-latest.tar.xz"; then
        echo "Firefox download failed."
        return 1
    fi

    temp_dir=$(mktemp -d)
    if ! tar -xf "$archive_dir/firefox-latest.tar.xz" -C "$temp_dir"; then
        echo "Could not extract the Firefox archive."
        rm -rf "$temp_dir"
        return 1
    fi

    if [[ ! -x "$temp_dir/firefox/firefox" ]]; then
        echo "The expected Firefox executable was not found."
        rm -rf "$temp_dir"
        return 1
    fi

    if [[ -e "$install_dir" ]]; then
        mv "$install_dir" \
            "${install_dir}.backup-$(date +%Y%m%d-%H%M%S)"
    fi

    mv "$temp_dir/firefox" "$install_dir"
    rm -rf "$temp_dir"

    echo
    echo "Firefox installed in: $install_dir"
    echo "Archive saved in: $archive_dir"
    echo "Launch with: $install_dir/firefox"
}

install_tor() {
    echo "Installing Tor Browser Launcher from Ubuntu's repositories..."
    sudo apt update
    sudo apt install -y torbrowser-launcher
    echo
    echo "Start the launcher with: torbrowser-launcher"
    echo "It will download the browser when you launch it."
}

while true; do
    echo
    echo "========================================"
    echo "             FIELDKIT"
    echo "      PERSONAL LINUX TOOLKIT"
    echo "========================================"
    echo

    for i in {1..10}; do
        printf "[%s] %s\n" "$i" "${names[$i]}"
    done

    echo
    echo "[A] Install all APT tool groups"
    echo "[F] Download and install standalone Firefox"
    echo "[T] Install Tor Browser Launcher"
    echo "[Q] Quit"
    echo

    read -r -p "Choose an option: " choice

    case "${choice,,}" in
        q)
            exit 0
            ;;
        a)
            install_tools {1..10}
            ;;
        f)
            install_firefox
            ;;
        t)
            install_tor
            ;;
        1|2|3|4|5|6|7|8|9|10)
            install_tools "$choice"
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac

    echo
    read -r -p "Press Enter to return to the menu..."
done
