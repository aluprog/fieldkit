
#!/usr/bin/env bash
set -Eeuo pipefail

# FieldKit - Interactive Linux tool installer
# Initial target: Ubuntu/Lubuntu 24.04

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
    echo "This first version supports Ubuntu and Lubuntu only."
    exit 1
fi

declare -A packages=(
    [1]="nmap"
    [2]="wireshark"
    [3]="python3 python3-venv python3-pip"
    [4]="git"
    [5]="curl wget"
    [6]="dnsutils net-tools"
    [7]="htop"
)

declare -A names=(
    [1]="Nmap"
    [2]="Wireshark"
    [3]="Python development tools"
    [4]="Git"
    [5]="curl and wget"
    [6]="DNS and network utilities"
    [7]="htop"
)

install_tools() {
    local selected=("$@")
    local pkgs=()

    for item in "${selected[@]}"; do
        read -r -a group <<< "${packages[$item]}"
        pkgs+=("${group[@]}")
    done

    echo
    echo "Selected tools:"
    printf ' - %s\n' "${selected[@]/# /}"
    printf 'Packages: %s\n' "${pkgs[*]}"
    echo

    read -r -p "Continue with installation? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || return 0

    sudo apt update
    sudo apt install "${pkgs[@]}"

    echo
    echo "Installation command completed."
    echo "Check the output above for any errors."
}

while true; do
    clear
    echo "=================================="
    echo "          FIELDKIT"
    echo "   Cybersecurity Tool Installer"
    echo "=================================="
    echo
    for i in {1..7}; do
        printf "[%s] %s\n" "$i" "${names[$i]}"
    done
    echo "[8] Metasploit Framework (setup pending)"
    echo
    echo "[A] Install all available tools"
    echo "[Q] Quit"
    echo

    read -r -p "Choose a tool: " choice

    case "${choice,,}" in
        q)
            exit 0
            ;;
        a)
            install_tools {1..7}
            read -r -p "Press Enter to return to the menu..."
            ;;
        1|2|3|4|5|6|7)
            install_tools "$choice"
            read -r -p "Press Enter to return to the menu..."
            ;;
        8)
            echo
            echo "Metasploit needs a separate installation module."
            echo "It is not included in the APT package list yet."
            echo "We will add a verified installation method next."
            read -r -p "Press Enter to return to the menu..."
            ;;
        *)
            echo "Invalid choice."
            sleep 1
            ;;
    esac
done
