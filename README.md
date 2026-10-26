# FieldKit

FieldKit is a modular, menu-driven personal Linux toolkit for rebuilding a learning and authorized security-testing workstation after a fresh installation.

## Main sections
1. **Install Tools** — seven categories, visible installation status, package-backend selection, and first-use guidance.
2. **Payloads & Scripts** — reviewed Bash/Python helpers, templates, and safe lab examples.
3. **Documentation** — TryHackMe, Hack The Box, and Real-World Assessments.
4. **Study & Practice** — foundations, concepts, tool learning, and progress tracking.
5. **System & Updates** — system information, logs, and explicitly confirmed system updates.

## Tool categories
- Network Reconnaissance & Analysis
- Exploitation Frameworks
- Web Application Security
- Credential Auditing
- Wireless & Active Directory
- Development & Utilities
- Privacy & Browser Tools

## Requirements and supported systems
Bash 4+, Linux with `/etc/os-release`, and `sudo` for system changes. Package backends: APT (Debian/Ubuntu family), DNF (Fedora/RHEL family), Pacman (Arch family), and Zypper (openSUSE). Automatic detection is the default; manual override is available. Package names and availability differ by distribution. Metasploit Framework uses Rapid7's official APT package setup script on Debian/Ubuntu after confirmation; Burp Suite uses the official PortSwigger interactive installer. Proton VPN uses the official Debian/Ubuntu repository package and verifies its published SHA-256 before installing. BloodHound CE needs Docker and at least 8 GB RAM; FieldKit does not silently install Docker as a hidden dependency, and this project’s older target PC is below the official memory minimum.

## Run
```bash
git clone https://github.com/aluprog/fieldkit.git
cd fieldkit
chmod +x fieldkit.sh
./fieldkit.sh
```

## Special installers
- **Metasploit Framework:** on Debian/Ubuntu x86_64, downloads the official `msfinstall` setup script from Rapid7's Metasploit Framework repository and runs it after confirmation. This configures the official APT package source and installs the CLI framework with its dependencies. It does **not** use the Metasploit Pro `.run` installer. It is package-managed, but the source is Rapid7's repository, not Ubuntu's default archive. Other Linux families receive official instructions only.
- **Burp Suite:** downloads and launches the official PortSwigger Linux installer after confirmation; choose Community Edition.
- **Proton VPN:** supported automated path is Debian/Ubuntu; verifies the official repository package checksum before adding it and installing the GUI package. Lubuntu integration may need extra configuration.
- **BloodHound CE:** requires a container runtime and at least 8 GB RAM according to upstream documentation. FieldKit displays this requirement rather than pretending it can complete installation on under-spec hardware.

## Safety
Use assessment tools only on systems you own or have explicit authorization to test. Read scripts before running them. FieldKit does not bundle large wordlists. Do not commit credentials, private keys, personal data, or confidential client evidence. Review logs before sharing them. Package installations and system updates require confirmation.

## Project structure
```text
fieldkit/
├── fieldkit.sh
├── core/                 # menus, catalogue, OS detection, status, logging
├── install/              # package-manager backend
├── payloads-scripts/
├── documentation/        # TryHackMe, Hack The Box, real-world assessments
├── study/
├── tests/
├── logs/                 # local runtime log; ignored by Git
├── README.md
├── SECURITY.md
└── CHANGELOG.md
```
MIT License; see `LICENSE`.
