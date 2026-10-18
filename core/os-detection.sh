#!/usr/bin/env bash
detect_os(){
  OS_ID=unknown; OS_PRETTY="Unknown Linux"; OS_LIKE=""
  if [[ -r /etc/os-release ]]; then source /etc/os-release; OS_ID="${ID:-unknown}"; OS_PRETTY="${PRETTY_NAME:-$OS_ID}"; OS_LIKE="${ID_LIKE:-}"; fi
  case " $OS_ID $OS_LIKE " in
    *" ubuntu "*|*" debian "*|*" linuxmint "*|*" kali "*|*" pop "*|*" raspbian "*|*" zorin "*|*" elementary "*) PKG_FAMILY=debian ;;
    *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*) PKG_FAMILY=fedora ;;
    *" arch "*|*" manjaro "*|*" endeavouros "*) PKG_FAMILY=arch ;;
    *" opensuse "*|*" suse "*) PKG_FAMILY=opensuse ;;
    *) PKG_FAMILY=unsupported ;;
  esac
  export OS_ID OS_PRETTY OS_LIKE PKG_FAMILY
}
select_os_family(){
  printf '\nDetected: %s (%s)\n1) Auto-detect  2) Debian/APT  3) Fedora/DNF  4) Arch/Pacman  5) openSUSE/Zypper\n'
  read -r -p 'Backend: ' a
  case "$a" in 1) detect_os;; 2) PKG_FAMILY=debian;; 3) PKG_FAMILY=fedora;; 4) PKG_FAMILY=arch;; 5) PKG_FAMILY=opensuse;; *) echo "Keeping $PKG_FAMILY";; esac
}
