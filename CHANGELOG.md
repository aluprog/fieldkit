# Changelog

## v0.4.1
- Changed Metasploit installation from the Metasploit Pro `.run` installer to the official Metasploit Framework package setup script for Debian/Ubuntu x86_64.
- Added explicit messaging distinguishing Framework CLI from Metasploit Pro and improved launcher verification.
- Removed bundled runtime log from the release archive.

## 0.4.0
- Added explicit installers for Metasploit, Burp Suite Community, and Proton VPN (Debian/Ubuntu).
- Added pre-install FYI prompts for tools that may already exist.
- BloodHound now explains its Docker dependency and 8 GB minimum rather than pretending to install it without prerequisites.
- Kept the clean category menu, blank-line layout, `o` OS selection, `b` back navigation, and category-wide install action.
- Removed the requested extra tools from the catalogue.


## 0.3.0
- Removed TShark, traceroute, venv, curl, wget, jq, ShellCheck, Docker, and Podman from the tool catalogue.
- Improved spacing and category navigation; `b` returns and `o` selects the package-manager family.
- Added category-level install-all action with one explicit confirmation.
- Added friendly tool names and targeted detection for common Metasploit, Burp Suite, BloodHound, Proton VPN, and standalone Firefox locations.

## 0.2.0
- Added the expanded seven-category catalogue and modular package backends.
- Added OS detection, installation guidance, status checks, documentation, study notes, and tests.
