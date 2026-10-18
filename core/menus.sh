#!/usr/bin/env bash
source "$FIELDKIT_ROOT/core/status.sh"
tools_menu(){
 while true; do
  clear 2>/dev/null || true
  printf '%s\n\n' '--- Install Tools ---'
  printf 'Detected OS: %s | Backend: %s\n\n' "$OS_PRETTY" "$PKG_FAMILY"
  for n in {1..7}; do printf '%s) %s\n' "$n" "$(category_name "$n")"; done
  printf '\nO) Select / override OS family\nB) Back\n'
  read -r -p 'Choose category: ' c
  case "$c" in
   1|2|3|4|5|6|7) category_menu "$c";;
   o|O) select_os_family; pause;;
   b|B) return;;
   *) echo 'Invalid choice'; pause;;
  esac
 done
}
category_menu(){
 local cat="$1" key i choice
 while true; do
  clear 2>/dev/null || true
  printf '%s\n\n' "--- $(category_name "$cat") ---"
  i=1
  while IFS='|' read -r key c package command method purpose first docs; do
   [[ "$c" == "$cat" ]] || continue
   printf '%2d) %-36s [%s]\n' "$i" "$(tool_name "$key")" "$(tool_status "$key")"
   ((i+=1))
  done <<< "$CATALOG"
  printf '\nA) Install all tools in this category\nB) Back\n'
  read -r -p 'Choose tool number or action: ' choice
  case "$choice" in
   b|B) return;;
   a|A) install_category "$cat";;
   *)
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice > 0 && choice < i )); then
     key="$(awk -F'|' -v c="$cat" -v n="$choice" '$2==c {i++; if(i==n){print $1; exit}}' <<< "$CATALOG")"
     tool_card "$key"
    else echo 'Invalid choice'; pause; fi
    ;;
  esac
 done
}
install_category(){
 local cat="$1" key c package command method purpose first docs
 printf '\nInstall all available package-managed tools in %s?\n' "$(category_name "$cat")"
 confirm 'Continue with this category' || return
 while IFS='|' read -r key c package command method purpose first docs; do
  [[ "$c" == "$cat" ]] || continue
  printf '\n--- %s ---\n' "$(tool_name "$key")"
  FIELDKIT_BATCH_CONFIRMED=1 install_tool "$key" || true
 done <<< "$CATALOG"
 pause
}
tool_card(){
 local key="$1" label purpose first docs status
 label="$(tool_name "$key")"; purpose="$(get_field "$key" 6)"; first="$(get_field "$key" 7)"; docs="$(get_field "$key" 8)"; status="$(tool_status "$key")"
 clear 2>/dev/null || true
 printf '%s\n\nStatus: %s\nPurpose: %s\nFirst step: %s\nOfficial documentation: %s\n\n' "$label" "$status" "$purpose" "$first" "$docs"
 if [[ "$status" != '✓ Installed' ]] && confirm "Install or show installation guidance for $label?"; then install_tool "$key" || true; fi
 pause
}
docs_menu(){
 while true; do
  clear 2>/dev/null || true
  printf '%s\n\n' '--- Documentation ---'
  printf '1) TryHackMe\n2) Hack The Box\n3) Real-World Assessments\n\nB) Back\n'
  read -r -p 'Choose: ' c
  case "$c" in
   1) open_folder "$FIELDKIT_ROOT/documentation/tryhackme";;
   2) open_folder "$FIELDKIT_ROOT/documentation/hackthebox";;
   3) open_folder "$FIELDKIT_ROOT/documentation/real-world-assessments";;
   b|B) return;;
   *) echo 'Invalid choice'; pause;;
  esac
 done
}
