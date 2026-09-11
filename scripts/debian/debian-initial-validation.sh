#!/usr/bin/env bash

# ============================================================
# Debian Initial Validation
# ============================================================
#
# Validates a Debian baseline installation before additional
# system roles, services, or applications are deployed.
#
# Checks:
#   - Required baseline packages
#   - System identity and resources
#   - Storage and SMART visibility
#   - Network configuration and connectivity
#   - DNS and time synchronization
#   - Systemd service health
#   - APT sources, repository access, and available updates
#
# Note:
#   Runtime output may contain environment-specific information
#   such as hostnames, IP addresses, gateways, and repository URLs.
#
# Intended to be run after the Debian baseline build is complete.
# ============================================================

set -u

set -u

# ============================================================
# Debian Initial Validation
# ============================================================

BASE_PACKAGES=(
  vim
  git
  curl
  wget
  htop
  tree
  bind9-dnsutils
  bash-completion
  cifs-utils
  rsync
  unzip
  ncdu
  smartmontools
  ca-certificates
)

PASS="[PASS]"
WARN="[WARN]"
FAIL="[FAIL]"
INFO="[INFO]"

HOSTNAME="$(hostname)"
OS_NAME="$(. /etc/os-release && echo "$PRETTY_NAME")"
KERNEL="$(uname -r)"
ARCH="$(uname -m)"
VIRTUALIZATION="$(systemd-detect-virt 2>/dev/null || echo "unknown")"

PRIMARY_IFACE="$(ip route show default 2>/dev/null | awk '{print $5; exit}')"
DEFAULT_GW="$(ip route show default 2>/dev/null | awk '{print $3; exit}')"

if [[ -n "${PRIMARY_IFACE:-}" ]]; then
  IPV4_ADDR="$(
    ip -4 addr show "$PRIMARY_IFACE" 2>/dev/null \
      | awk '/inet / {print $2; exit}'
  )"

  IPV6_ADDR="$(
    ip -6 addr show "$PRIMARY_IFACE" scope global 2>/dev/null \
      | awk '/inet6 / {print $2; exit}'
  )"
else
  IPV4_ADDR="N/A"
  IPV6_ADDR="N/A"
fi

[[ -z "${IPV4_ADDR:-}" ]] && IPV4_ADDR="N/A"
[[ -z "${IPV6_ADDR:-}" ]] && IPV6_ADDR="N/A"
[[ -z "${DEFAULT_GW:-}" ]] && DEFAULT_GW="N/A"

ROOT_USAGE="$(
  df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}'
)"

ROOT_FREE="$(
  df -h / | awk 'NR==2 {print $4}'
)"

ROOT_PERCENT="$(
  df / | awk 'NR==2 {gsub("%","",$5); print $5}'
)"

ROOT_INODE_PERCENT="$(
  df -i / | awk 'NR==2 {gsub("%","",$5); print $5}'
)"

MEMORY_TOTAL="$(free -h | awk '/^Mem:/ {print $2}')"
MEMORY_USED="$(free -h | awk '/^Mem:/ {print $3}')"
SWAP_TOTAL="$(free -h | awk '/^Swap:/ {print $2}')"

SMART_DEVICES="$(
  smartctl --scan 2>/dev/null \
    | awk '{print $1}' \
    | paste -sd ', ' -
)"

[[ -z "$SMART_DEVICES" ]] && SMART_DEVICES="None detected"

echo "========================================"
echo " Debian Initial Validation"
echo "========================================"
echo

# ------------------------------------------------------------
# Package Validation
# ------------------------------------------------------------

echo "=== Base Package Validation ==="

missing_packages=()

for pkg in "${BASE_PACKAGES[@]}"; do
  if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null \
      | grep -q "install ok installed"; then
    printf "%-20s %s\n" "$pkg" "$PASS"
  else
    printf "%-20s %s\n" "$pkg" "$FAIL"
    missing_packages+=("$pkg")
  fi
done

echo

# ------------------------------------------------------------
# Storage Validation
# ------------------------------------------------------------

echo "=== Storage Validation ==="

if (( ROOT_PERCENT < 80 )); then
  echo "$PASS Root filesystem usage: ${ROOT_PERCENT}%"
elif (( ROOT_PERCENT < 90 )); then
  echo "$WARN Root filesystem usage: ${ROOT_PERCENT}%"
else
  echo "$FAIL Root filesystem usage: ${ROOT_PERCENT}%"
fi

if (( ROOT_INODE_PERCENT < 80 )); then
  echo "$PASS Root inode usage: ${ROOT_INODE_PERCENT}%"
elif (( ROOT_INODE_PERCENT < 90 )); then
  echo "$WARN Root inode usage: ${ROOT_INODE_PERCENT}%"
else
  echo "$FAIL Root inode usage: ${ROOT_INODE_PERCENT}%"
fi

if smartctl --scan >/dev/null 2>&1; then
  echo "$PASS smartmontools device scan completed"
else
  echo "$WARN SMART device scan returned an error"
fi

echo

# ------------------------------------------------------------
# System Identity
# ------------------------------------------------------------

echo "=== System Identity ==="

echo "Hostname:          $HOSTNAME"
echo "Operating System:  $OS_NAME"
echo "Kernel:            $KERNEL"
echo "Architecture:      $ARCH"
echo "Virtualization:    $VIRTUALIZATION"

echo

# ------------------------------------------------------------
# Resource Validation
# ------------------------------------------------------------

echo "=== Resource Validation ==="

echo "$INFO Memory usage: ${MEMORY_USED} / ${MEMORY_TOTAL}"
echo "$INFO Swap configured: ${SWAP_TOTAL}"

echo

# ------------------------------------------------------------
# Network Validation
# ------------------------------------------------------------

echo "=== Network Validation ==="

if [[ -n "${PRIMARY_IFACE:-}" ]]; then
  echo "$PASS Primary interface detected: $PRIMARY_IFACE"
else
  echo "$FAIL No default network interface detected"
fi

if [[ "$IPV4_ADDR" != "N/A" ]]; then
  echo "$PASS IPv4 address: $IPV4_ADDR"
else
  echo "$WARN No IPv4 address detected"
fi

if [[ "$DEFAULT_GW" != "N/A" ]]; then
  echo "$PASS Default gateway: $DEFAULT_GW"
else
  echo "$FAIL No default gateway detected"
fi

echo

# ------------------------------------------------------------
# Connectivity Validation
# ------------------------------------------------------------

echo "=== Connectivity Validation ==="

if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
  INTERNET_STATUS="PASS"
  echo "$PASS Internet connectivity"
else
  INTERNET_STATUS="FAIL"
  echo "$FAIL Internet connectivity"
fi

if getent hosts google.com >/dev/null 2>&1; then
  DNS_STATUS="PASS"
  echo "$PASS DNS resolution"
else
  DNS_STATUS="FAIL"
  echo "$FAIL DNS resolution"
fi

echo

# ------------------------------------------------------------
# System Health Validation
# ------------------------------------------------------------

echo "=== System Health Validation ==="

FAILED_UNITS="$(
  systemctl --failed --no-legend 2>/dev/null \
    | grep -c .
)"

if (( FAILED_UNITS == 0 )); then
  SYSTEMD_STATUS="PASS"
  echo "$PASS No failed systemd units"
else
  SYSTEMD_STATUS="FAIL"
  echo "$FAIL Failed systemd units detected: $FAILED_UNITS"
fi

if timedatectl show -p NTPSynchronized --value 2>/dev/null \
    | grep -q '^yes$'; then
  TIME_STATUS="PASS"
  echo "$PASS System clock synchronized"
else
  TIME_STATUS="WARN"
  echo "$WARN System clock is not synchronized"
fi

echo

# ------------------------------------------------------------
# APT Sources
# ------------------------------------------------------------

echo "=== APT Sources ==="

APT_SOURCE_FOUND=0

if [[ -f /etc/apt/sources.list ]]; then
  if grep -Ev '^[[:space:]]*(#|$)' /etc/apt/sources.list | grep -q .; then
    echo "/etc/apt/sources.list:"
    grep -Ev '^[[:space:]]*(#|$)' /etc/apt/sources.list
    APT_SOURCE_FOUND=1
  fi
fi

if compgen -G "/etc/apt/sources.list.d/*.list" >/dev/null; then
  for file in /etc/apt/sources.list.d/*.list; do
    if grep -Ev '^[[:space:]]*(#|$)' "$file" | grep -q .; then
      echo
      echo "$file:"
      grep -Ev '^[[:space:]]*(#|$)' "$file"
      APT_SOURCE_FOUND=1
    fi
  done
fi

if compgen -G "/etc/apt/sources.list.d/*.sources" >/dev/null; then
  for file in /etc/apt/sources.list.d/*.sources; do
    echo
    echo "$file:"
    cat "$file"
    APT_SOURCE_FOUND=1
  done
fi

if (( APT_SOURCE_FOUND == 0 )); then
  echo "$WARN No active APT sources detected"
fi

echo

# ------------------------------------------------------------
# APT Repository Validation
# ------------------------------------------------------------

echo "=== APT Repository Validation ==="

if apt-get update -qq >/dev/null 2>&1; then
  APT_STATUS="PASS"
  echo "$PASS APT repositories reachable"
else
  APT_STATUS="FAIL"
  echo "$FAIL APT repository update failed"
fi

UPDATES_AVAILABLE="$(
  apt list --upgradable 2>/dev/null \
    | tail -n +2 \
    | grep -c .
)"

echo "$INFO Available package updates: $UPDATES_AVAILABLE"

echo

# ------------------------------------------------------------
# Package Summary
# ------------------------------------------------------------

if (( ${#missing_packages[@]} == 0 )); then
  PACKAGE_STATUS="PASS"
  PACKAGE_SUMMARY="${#BASE_PACKAGES[@]}/${#BASE_PACKAGES[@]} installed"
else
  PACKAGE_STATUS="FAIL"
  INSTALLED_COUNT=$((${#BASE_PACKAGES[@]} - ${#missing_packages[@]}))
  PACKAGE_SUMMARY="${INSTALLED_COUNT}/${#BASE_PACKAGES[@]} installed"
fi

# ------------------------------------------------------------
# Validation Summary
# ------------------------------------------------------------

echo "========================================"
echo " Validation Summary"
echo "========================================"

printf "%-22s %-40s\n" "Item" "Value"
printf "%-22s %-40s\n" \
  "----------------------" \
  "----------------------------------------"

printf "%-22s %-40s\n" "Hostname" "$HOSTNAME"
printf "%-22s %-40s\n" "Operating System" "$OS_NAME"
printf "%-22s %-40s\n" "Kernel" "$KERNEL"
printf "%-22s %-40s\n" "Architecture" "$ARCH"
printf "%-22s %-40s\n" "Virtualization" "$VIRTUALIZATION"
printf "%-22s %-40s\n" "Memory" "${MEMORY_USED} / ${MEMORY_TOTAL}"
printf "%-22s %-40s\n" "Swap" "$SWAP_TOTAL"
printf "%-22s %-40s\n" "Primary Interface" "${PRIMARY_IFACE:-N/A}"
printf "%-22s %-40s\n" "IPv4 Address" "$IPV4_ADDR"
printf "%-22s %-40s\n" "IPv6 Address" "$IPV6_ADDR"
printf "%-22s %-40s\n" "Default Gateway" "$DEFAULT_GW"
printf "%-22s %-40s\n" "Root Filesystem" "$ROOT_USAGE"
printf "%-22s %-40s\n" "Root Free Space" "$ROOT_FREE"
printf "%-22s %-40s\n" "Root Inodes" "${ROOT_INODE_PERCENT}% used"
printf "%-22s %-40s\n" "SMART Devices" "$SMART_DEVICES"
printf "%-22s %-40s\n" "Base Packages" "$PACKAGE_SUMMARY"
printf "%-22s %-40s\n" "Internet" "$INTERNET_STATUS"
printf "%-22s %-40s\n" "DNS" "$DNS_STATUS"
printf "%-22s %-40s\n" "Time Sync" "$TIME_STATUS"
printf "%-22s %-40s\n" "Failed Services" "$FAILED_UNITS"
printf "%-22s %-40s\n" "APT Repositories" "$APT_STATUS"
printf "%-22s %-40s\n" "Available Updates" "$UPDATES_AVAILABLE"

# ------------------------------------------------------------
# Missing Package Remediation
# ------------------------------------------------------------

if (( ${#missing_packages[@]} > 0 )); then
  echo
  echo "Missing baseline packages:"
  printf '  - %s\n' "${missing_packages[@]}"

  echo
  echo "Install missing packages with:"
  echo
  echo "sudo apt install -y \\"

  for i in "${!missing_packages[@]}"; do
    pkg="${missing_packages[$i]}"

    if (( i == ${#missing_packages[@]} - 1 )); then
      echo "  $pkg"
    else
      echo "  $pkg \\"
    fi
  done
fi

echo
echo "========================================"

if [[ "$PACKAGE_STATUS" == "PASS" \
      && "$INTERNET_STATUS" == "PASS" \
      && "$DNS_STATUS" == "PASS" \
      && "$SYSTEMD_STATUS" == "PASS" \
      && "$APT_STATUS" == "PASS" ]]; then
  echo " Overall Status: PASS"
else
  echo " Overall Status: REVIEW REQUIRED"
fi

echo "========================================"
