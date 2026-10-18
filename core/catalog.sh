#!/usr/bin/env bash
# key|category|package|command|method|purpose|first-use|documentation
CATALOG=$(cat <<'EOF'
nmap|1|nmap|nmap|package|Host and service discovery|nmap --version; safe local exercise: nmap 127.0.0.1|https://nmap.org/book/man.html
wireshark|1|wireshark|wireshark|package|Graphical packet protocol analysis|Launch Wireshark from the desktop menu|https://www.wireshark.org/docs/
tcpdump|1|tcpdump|tcpdump|package|Terminal packet capture|tcpdump --version; review capture permissions first|https://www.tcpdump.org/manpages/tcpdump.1.html
dig|1|dnsutils|dig|package|DNS troubleshooting|dig example.com|https://bind9.readthedocs.io/
whois|1|whois|whois|package|Domain/IP registration lookups|whois example.com|https://manpages.debian.org/whois
metasploit|2|metasploit-framework|msfconsole|installer|Exploitation framework for authorized labs|Follow official setup guide; use an isolated lab|https://docs.metasploit.com/
setoolkit|2|set|setoolkit|repository-check|Social-engineering simulation toolkit|Use only in authorized simulations|https://github.com/trustedsec/social-engineer-toolkit
burpsuite|2||burpsuite|installer|Web testing proxy|Install using official PortSwigger instructions|https://portswigger.net/burp/documentation
sqlmap|3|sqlmap|sqlmap|package|SQL injection testing in authorized labs|sqlmap --version|https://sqlmap.org/
nikto|3|nikto|nikto|package|Web-server security scanner|nikto -Help|https://github.com/sullo/nikto
gobuster|3|gobuster|gobuster|package|Directory and DNS discovery|gobuster --help|https://github.com/OJ/gobuster
zaproxy|3|zaproxy|zaproxy|repository-check|OWASP web application testing proxy|Launch OWASP ZAP from the application menu|https://www.zaproxy.org/getting-started/
john|4|john|john|package|Password hash auditing|john --list=formats|https://www.openwall.com/john/
hydra|4|hydra|hydra|package|Login auditing in authorized labs|hydra -h; use only lab accounts|https://github.com/vanhauser-thc/thc-hydra
aircrack-ng|5|aircrack-ng|aircrack-ng|package|Wireless security auditing|aircrack-ng --help; compatible Wi-Fi hardware required|https://www.aircrack-ng.org/documentation.html
bloodhound|5|bloodhound|bloodhound|upstream|Active Directory relationship analysis|Follow upstream setup; additional components may be required|https://bloodhound.specterops.io/
impacket|5|python3-impacket|impacket|repository-check|Python networking and Windows protocol toolkit|python3 -m pip show impacket|https://github.com/fortra/impacket
python3|6|python3|python3|package|Python runtime|python3 --version|https://docs.python.org/3/
git|6|git|git|package|Version control|git --version|https://git-scm.com/doc
firefox-standalone|7||firefox|manual|Mozilla archive-based browser workflow|Use Mozilla's official Linux archive instructions|https://support.mozilla.org/en-US/kb/install-firefox-linux
tor-browser|7|torbrowser-launcher|torbrowser-launcher|repository-check|Privacy-oriented browser launcher|torbrowser-launcher then follow prompts|https://tb-manual.torproject.org/
proton-vpn|7||protonvpn|installer|VPN client; service/account requirements apply|Follow official Proton Linux setup guide|https://protonvpn.com/support/linux-vpn-tool/
keepassxc|7|keepassxc|keepassxc|package|Local password manager|keepassxc|https://keepassxc.org/docs/
EOF
)
get_field(){ awk -F'|' -v k="$1" -v n="$2" '$1==k {print $n; exit}' <<< "$CATALOG"; }
tool_name(){
 case "$1" in
  nmap) echo 'Nmap';; wireshark) echo 'Wireshark';; tcpdump) echo 'tcpdump';; dig) echo 'dig (DNS tools)';; whois) echo 'whois';;
  metasploit) echo 'Metasploit Framework';; setoolkit) echo 'Social-Engineer Toolkit (SET)';; burpsuite) echo 'Burp Suite Community Edition';;
  sqlmap) echo 'sqlmap';; nikto) echo 'Nikto';; gobuster) echo 'Gobuster';; zaproxy) echo 'OWASP ZAP';;
  john) echo 'John the Ripper';; hydra) echo 'Hydra';; aircrack-ng) echo 'Aircrack-ng';; bloodhound) echo 'BloodHound';; impacket) echo 'Impacket';;
  python3) echo 'Python 3';; git) echo 'Git';; firefox-standalone) echo 'Firefox (standalone archive)';; tor-browser) echo 'Tor Browser';; proton-vpn) echo 'Proton VPN';; keepassxc) echo 'KeePassXC';;
  *) echo "$1";;
 esac
}
category_name(){ case "$1" in 1) echo "Network Reconnaissance & Analysis";; 2) echo "Exploitation Frameworks";; 3) echo "Web Application Security";; 4) echo "Credential Auditing";; 5) echo "Wireless & Active Directory";; 6) echo "Development & Utilities";; 7) echo "Privacy & Browser Tools";; esac; }
