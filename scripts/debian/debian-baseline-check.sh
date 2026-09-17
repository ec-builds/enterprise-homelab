#!/usr/bin/env bash

# ============================================================
# Debian Baseline & Template Readiness Check
# ============================================================
#
# Validates the standard Debian baseline and optionally performs
# template-specific readiness checks.
#
# Usage:
#   sudo bash debian-baseline-check.sh
#   sudo bash debian-baseline-check.sh --template
#   bash debian-baseline-check.sh --help
#
# Baseline mode validates:
#   - Debian version and architecture
#   - Required baseline packages
#   - Administrative access
#   - SSH configuration
#   - Proxmox guest integration
#   - Optional services
#   - Network connectivity and DNS
#   - Resolver configuration
#   - APT repository access and updates
#   - Time synchronization
#   - Storage
#   - Systemd service health
#
# Template mode additionally validates:
#   - Machine ID state
#   - SSH host keys
#   - D-Bus machine ID
#   - Additional persistent mounts
# ============================================================

set -u

# ------------------------------------------------------------
# Initial Notice
# ------------------------------------------------------------

echo "NOTE: For VM template readiness checks, run this script with --template."
echo "      Example: sudo bash $0 --template"
echo

# ------------------------------------------------------------
# Status Labels
# ------------------------------------------------------------

PASS="[PASS]"
WARN="[WARN]"
FAIL="[FAIL]"
INFO="[INFO]"

PASS_COUNT=0
INFO_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

INFO_MESSAGES=()
WARNINGS=()
FAILURES=()

# ------------------------------------------------------------
# Mode Selection
# ------------------------------------------------------------

TEMPLATE_MODE=false

case "${1:-}" in
    "")
        ;;
    --template)
        TEMPLATE_MODE=true
        ;;
    -h|--help)
        echo "Usage: $0 [--template]"
        echo
        echo "  No option    Run Debian baseline validation"
        echo "  --template   Run baseline validation plus template readiness checks"
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--template]"
        exit 2
        ;;
esac

# ------------------------------------------------------------
# Privilege Check
# ------------------------------------------------------------

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run with sudo or as root."
    echo "Usage: sudo bash $0 [--template]"
    exit 2
fi

# ------------------------------------------------------------
# Output Functions
# ------------------------------------------------------------

pass() {
    echo "$PASS $1"
    ((PASS_COUNT++))
}

info() {
    echo "$INFO $1"
    INFO_MESSAGES+=("$1")
    ((INFO_COUNT++))
}

warn() {
    echo "$WARN $1"
    WARNINGS+=("$1")
    ((WARN_COUNT++))
}

fail() {
    echo "$FAIL $1"
    FAILURES+=("$1")
    ((FAIL_COUNT++))
}

# ------------------------------------------------------------
# System Information
# ------------------------------------------------------------

HOSTNAME_CURRENT="$(hostname)"
OS_NAME="$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-Unknown}")"
OS_ID="$(. /etc/os-release 2>/dev/null && echo "${ID:-unknown}")"
OS_VERSION="$(. /etc/os-release 2>/dev/null && echo "${VERSION_ID:-unknown}")"
KERNEL="$(uname -r)"
ARCH="$(uname -m)"
VIRTUALIZATION="$(systemd-detect-virt 2>/dev/null || echo "unknown")"

PRIMARY_IFACE="$(
    ip route show default 2>/dev/null \
        | awk '{print $5; exit}'
)"

DEFAULT_GW="$(
    ip route show default 2>/dev/null \
        | awk '{print $3; exit}'
)"

if [[ -n "${PRIMARY_IFACE:-}" ]]; then
    IPV4_ADDR="$(
        ip -4 addr show "$PRIMARY_IFACE" 2>/dev/null \
            | awk '/inet / {print $2; exit}'
    )"
else
    IPV4_ADDR=""
fi

[[ -z "${PRIMARY_IFACE:-}" ]] && PRIMARY_IFACE="N/A"
[[ -z "${DEFAULT_GW:-}" ]] && DEFAULT_GW="N/A"
[[ -z "${IPV4_ADDR:-}" ]] && IPV4_ADDR="N/A"

ROOT_USAGE="$(
    df -h / 2>/dev/null \
        | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}'
)"

ROOT_PERCENT="$(
    df -P / 2>/dev/null \
        | awk 'NR==2 {gsub("%","",$5); print $5}'
)"

MEMORY_TOTAL="$(free -h | awk '/^Mem:/ {print $2}')"
MEMORY_USED="$(free -h | awk '/^Mem:/ {print $3}')"
SWAP_TOTAL="$(free -h | awk '/^Swap:/ {print $2}')"

# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

echo "========================================"

if [[ "$TEMPLATE_MODE" == true ]]; then
    echo " Debian Baseline & Template Readiness"
else
    echo " Debian Baseline Validation"
fi

echo "========================================"
echo

# ------------------------------------------------------------
# Operating System
# ------------------------------------------------------------

echo "=== Operating System ==="

if [[ "$OS_ID" == "debian" ]]; then
    echo "$PASS Debian detected: $OS_NAME"
    ((PASS_COUNT++))
else
    fail "System is not Debian"
fi

if [[ "$OS_VERSION" == "13" ]]; then
    echo "$PASS Debian 13 detected"
    ((PASS_COUNT++))
else
    warn "Expected Debian 13; detected version $OS_VERSION"
fi

if [[ "$ARCH" == "x86_64" ]]; then
    echo "$PASS Architecture: $ARCH"
    ((PASS_COUNT++))
else
    warn "Unexpected architecture: $ARCH"
fi

echo

# ------------------------------------------------------------
# System Identity
# ------------------------------------------------------------

echo "=== System Identity ==="

echo "Hostname:          $HOSTNAME_CURRENT"
echo "Operating System:  $OS_NAME"
echo "Kernel:            $KERNEL"
echo "Architecture:      $ARCH"
echo "Virtualization:    $VIRTUALIZATION"

if [[ -n "$HOSTNAME_CURRENT" ]]; then
    ((PASS_COUNT++))
else
    fail "Hostname not configured"
fi

if hostnamectl >/dev/null 2>&1; then
    ((PASS_COUNT++))
else
    fail "hostnamectl failed"
fi

echo

# ------------------------------------------------------------
# Resource Validation
# ------------------------------------------------------------

echo "=== Resource Validation ==="

echo "$INFO Memory usage: ${MEMORY_USED} / ${MEMORY_TOTAL}"
echo "$INFO Swap configured: ${SWAP_TOTAL}"

((INFO_COUNT+=2))

echo

# ------------------------------------------------------------
# Baseline Packages
# ------------------------------------------------------------

echo "=== Baseline Package Validation ==="

BASELINE_PACKAGES=(
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
    resolvconf
)

BASELINE_INSTALLED=0
BASELINE_TOTAL="${#BASELINE_PACKAGES[@]}"

for package in "${BASELINE_PACKAGES[@]}"; do

    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null \
        | grep -q "install ok installed"; then

        printf "%-20s %s\n" "$package" "$PASS"
        ((BASELINE_INSTALLED++))
        ((PASS_COUNT++))

    else

        printf "%-20s %s\n" "$package" "$FAIL"
        FAILURES+=("$package not installed")
        ((FAIL_COUNT++))

    fi

done

echo

if command -v dig >/dev/null 2>&1; then
    pass "DNS utilities functional (dig available)"
else
    fail "DNS utilities not functional (dig unavailable)"
fi

echo

# ------------------------------------------------------------
# Administrative Access
# ------------------------------------------------------------

echo "=== Administrative Access ==="

if dpkg-query -W -f='${Status}' sudo 2>/dev/null \
    | grep -q "install ok installed"; then
    pass "sudo installed"
else
    fail "sudo not installed"
fi

echo

# ------------------------------------------------------------
# SSH
# ------------------------------------------------------------

echo "=== SSH Validation ==="

if dpkg-query -W -f='${Status}' openssh-server 2>/dev/null \
    | grep -q "install ok installed"; then
    pass "OpenSSH Server installed"
else
    fail "OpenSSH Server not installed"
fi

if systemctl is-active --quiet ssh; then
    pass "SSH service running"
else
    fail "SSH service not running"
fi

if systemctl is-enabled --quiet ssh 2>/dev/null; then
    pass "SSH service enabled"
else
    warn "SSH service not enabled"
fi

echo

# ------------------------------------------------------------
# Proxmox Guest Integration
# ------------------------------------------------------------

echo "=== Proxmox Guest Integration ==="

if dpkg-query -W -f='${Status}' qemu-guest-agent 2>/dev/null \
    | grep -q "install ok installed"; then
    pass "qemu-guest-agent installed"
else
    fail "qemu-guest-agent not installed"
fi

if systemctl is-active --quiet qemu-guest-agent; then
    pass "QEMU Guest Agent running"
else
    fail "QEMU Guest Agent not running"
fi

echo

# ------------------------------------------------------------
# Optional Services
# ------------------------------------------------------------

echo "=== Optional Services ==="

if dpkg-query -W -f='${Status}' avahi-daemon 2>/dev/null \
    | grep -q "install ok installed"; then

    info "Avahi installed (optional)"

    if systemctl is-active --quiet avahi-daemon; then
        pass "Avahi daemon running"
    else
        warn "Avahi daemon installed but not running"
    fi

    if systemctl is-enabled --quiet avahi-daemon 2>/dev/null; then
        pass "Avahi daemon enabled"
    else
        warn "Avahi daemon installed but not enabled"
    fi

else

    info "Avahi not installed (optional; not included in template)"

fi

echo

# ------------------------------------------------------------
# Network Validation
# ------------------------------------------------------------

echo "=== Network Validation ==="

if [[ "$PRIMARY_IFACE" != "N/A" ]]; then
    pass "Primary interface detected: $PRIMARY_IFACE"
else
    fail "No default network interface detected"
fi

if [[ "$IPV4_ADDR" != "N/A" ]]; then
    pass "IPv4 address: $IPV4_ADDR"
else
    fail "No active IPv4 address detected"
fi

if [[ "$DEFAULT_GW" != "N/A" ]]; then
    pass "Default gateway: $DEFAULT_GW"
else
    fail "Default route not configured"
fi

echo

# ------------------------------------------------------------
# Connectivity Validation
# ------------------------------------------------------------

echo "=== Connectivity Validation ==="

if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
    INTERNET_STATUS="PASS"
    pass "Internet connectivity"
else
    INTERNET_STATUS="FAIL"
    fail "Internet connectivity failed"
fi

if getent hosts debian.org >/dev/null 2>&1; then
    DNS_STATUS="PASS"
    pass "DNS resolution"
else
    DNS_STATUS="FAIL"
    fail "DNS resolution failed"
fi

echo

# ------------------------------------------------------------
# Resolver Validation
# ------------------------------------------------------------

echo "=== Resolver Validation ==="

RESOLVER_TYPE="Unknown"

if [[ -e /etc/resolv.conf ]]; then

    pass "/etc/resolv.conf exists"

    if grep -Eq '^[[:space:]]*nameserver[[:space:]]+' /etc/resolv.conf; then
        pass "Resolver contains at least one nameserver"
    else
        fail "/etc/resolv.conf contains no nameserver entries"
    fi

    if [[ -L /etc/resolv.conf ]]; then

        RESOLV_TARGET="$(readlink -f /etc/resolv.conf 2>/dev/null || true)"

        if [[ "$RESOLV_TARGET" == *"/run/resolvconf/"* ]]; then
            RESOLVER_TYPE="resolvconf"
            pass "/etc/resolv.conf managed by resolvconf"

        elif [[ "$RESOLV_TARGET" == *"/run/systemd/resolve/"* ]]; then
            RESOLVER_TYPE="systemd-resolved"
            pass "/etc/resolv.conf managed by systemd-resolved"

        else
            RESOLVER_TYPE="Managed symlink"
            info "/etc/resolv.conf is a managed symlink"
        fi

    elif grep -qi "generated by resolvconf" /etc/resolv.conf; then

        RESOLVER_TYPE="resolvconf"
        pass "/etc/resolv.conf managed by resolvconf"

    else

        RESOLVER_TYPE="Regular file"
        info "/etc/resolv.conf is a regular file"

    fi

else

    RESOLVER_TYPE="Missing"
    fail "/etc/resolv.conf does not exist"

fi

echo

# ------------------------------------------------------------
# APT Repository Validation
# ------------------------------------------------------------

echo "=== APT Repository Validation ==="

if apt-get update -qq >/dev/null 2>&1; then

    APT_STATUS="PASS"
    pass "APT repositories reachable"

    UPGRADE_COUNT="$(
        apt-get -s upgrade 2>/dev/null \
            | awk '/^[0-9]+ upgraded/ {print $1}'
    )"

    UPGRADE_COUNT="${UPGRADE_COUNT:-0}"

    if [[ "$UPGRADE_COUNT" -eq 0 ]]; then
        pass "No pending package upgrades"
    else
        info "$UPGRADE_COUNT package upgrade(s) pending"
    fi

else

    APT_STATUS="FAIL"
    UPGRADE_COUNT="Unknown"

    fail "Unable to reach APT repositories"
    warn "Pending package upgrades not evaluated because package metadata could not be refreshed"

fi

echo

# ------------------------------------------------------------
# Time Synchronization
# ------------------------------------------------------------

echo "=== Time Synchronization ==="

if timedatectl show -p NTPSynchronized --value 2>/dev/null \
    | grep -q '^yes$'; then

    TIME_STATUS="PASS"
    pass "System clock synchronized"

else

    TIME_STATUS="WARN"
    warn "System clock not synchronized"

fi

echo

# ------------------------------------------------------------
# Storage
# ------------------------------------------------------------

echo "=== Storage Validation ==="

if [[ "$ROOT_PERCENT" =~ ^[0-9]+$ ]]; then

    if (( ROOT_PERCENT < 80 )); then
        pass "Root filesystem usage: ${ROOT_PERCENT}%"
    elif (( ROOT_PERCENT < 90 )); then
        warn "Root filesystem usage: ${ROOT_PERCENT}%"
    else
        fail "Root filesystem usage: ${ROOT_PERCENT}%"
    fi

else

    warn "Unable to determine root filesystem usage"

fi

if smartctl --scan >/dev/null 2>&1; then
    pass "smartmontools device scan completed"
else
    warn "SMART device scan returned an error"
fi

echo

# ------------------------------------------------------------
# System Health
# ------------------------------------------------------------

echo "=== System Health Validation ==="

FAILED_UNITS="$(
    systemctl --failed --no-legend 2>/dev/null \
        | grep -c '[^[:space:]]' || true
)"

if [[ "$FAILED_UNITS" -eq 0 ]]; then

    SYSTEMD_STATUS="PASS"
    pass "No failed systemd units"

else

    SYSTEMD_STATUS="FAIL"
    fail "$FAILED_UNITS failed systemd unit(s) detected"

fi

echo

# ------------------------------------------------------------
# Template Readiness
# ------------------------------------------------------------

MACHINE_ID_STATUS="N/A"
SSH_KEYS_STATUS="N/A"
DBUS_ID_STATUS="N/A"
CUSTOM_MOUNTS_STATUS="N/A"

if [[ "$TEMPLATE_MODE" == true ]]; then

    echo "=== Template Readiness ==="

    if [[ -s /etc/machine-id ]]; then

        MACHINE_ID_STATUS="CLEAR REQUIRED"
        warn "/etc/machine-id is populated — clear during final template preparation"

    else

        MACHINE_ID_STATUS="PASS"
        pass "/etc/machine-id already cleared"

    fi

    if compgen -G "/etc/ssh/ssh_host_*" >/dev/null; then

        SSH_KEYS_STATUS="CLEAR REQUIRED"
        warn "SSH host keys exist — remove during final template preparation"

    else

        SSH_KEYS_STATUS="PASS"
        pass "SSH host keys cleared"

    fi

    if [[ -L /var/lib/dbus/machine-id ]]; then

        DBUS_ID_STATUS="SYMLINK"
        pass "/var/lib/dbus/machine-id is a symlink"

    elif [[ -s /var/lib/dbus/machine-id ]]; then

        DBUS_ID_STATUS="CLEAR REQUIRED"
        warn "/var/lib/dbus/machine-id contains machine-specific state"

    else

        DBUS_ID_STATUS="PASS"
        pass "/var/lib/dbus/machine-id contains no machine-specific state"

    fi

    CUSTOM_MOUNTS="$(
        awk '
            /^[[:space:]]*#/ || NF == 0 { next }
            $2 == "/" || $2 == "/boot" || $2 == "/boot/efi" { next }
            $3 == "swap" { next }
            $2 ~ "^/media/cdrom" || $2 ~ "^/mnt/cdrom" { next }
            { print }
        ' /etc/fstab 2>/dev/null
    )"

    if [[ -n "$CUSTOM_MOUNTS" ]]; then

        CUSTOM_MOUNTS_STATUS="REVIEW"
        warn "Additional persistent mounts found in /etc/fstab"

        echo
        echo "$CUSTOM_MOUNTS"

    else

        CUSTOM_MOUNTS_STATUS="PASS"
        pass "No additional persistent mounts found"

    fi

    echo

fi

# ------------------------------------------------------------
# Baseline Package Summary
# ------------------------------------------------------------

if (( BASELINE_INSTALLED == BASELINE_TOTAL )); then
    PACKAGE_STATUS="PASS"
else
    PACKAGE_STATUS="FAIL"
fi

PACKAGE_SUMMARY="${BASELINE_INSTALLED}/${BASELINE_TOTAL} installed"

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

printf "%-22s %-40s\n" "Mode" \
    "$([[ "$TEMPLATE_MODE" == true ]] && echo "Template" || echo "Baseline")"

printf "%-22s %-40s\n" "Hostname" "$HOSTNAME_CURRENT"
printf "%-22s %-40s\n" "Operating System" "$OS_NAME"
printf "%-22s %-40s\n" "Kernel" "$KERNEL"
printf "%-22s %-40s\n" "Architecture" "$ARCH"
printf "%-22s %-40s\n" "Virtualization" "$VIRTUALIZATION"
printf "%-22s %-40s\n" "Memory" "${MEMORY_USED} / ${MEMORY_TOTAL}"
printf "%-22s %-40s\n" "Swap" "$SWAP_TOTAL"
printf "%-22s %-40s\n" "Primary Interface" "$PRIMARY_IFACE"
printf "%-22s %-40s\n" "IPv4 Address" "$IPV4_ADDR"
printf "%-22s %-40s\n" "Default Gateway" "$DEFAULT_GW"
printf "%-22s %-40s\n" "Root Filesystem" "$ROOT_USAGE"
printf "%-22s %-40s\n" "Base Packages" "$PACKAGE_SUMMARY"
printf "%-22s %-40s\n" "Resolver" "$RESOLVER_TYPE"
printf "%-22s %-40s\n" "Internet" "$INTERNET_STATUS"
printf "%-22s %-40s\n" "DNS" "$DNS_STATUS"
printf "%-22s %-40s\n" "Time Sync" "$TIME_STATUS"
printf "%-22s %-40s\n" "Failed Services" "$FAILED_UNITS"
printf "%-22s %-40s\n" "APT Repositories" "$APT_STATUS"
printf "%-22s %-40s\n" "Available Updates" "$UPGRADE_COUNT"

if [[ "$TEMPLATE_MODE" == true ]]; then
    printf "%-22s %-40s\n" "Machine ID" "$MACHINE_ID_STATUS"
    printf "%-22s %-40s\n" "SSH Host Keys" "$SSH_KEYS_STATUS"
    printf "%-22s %-40s\n" "D-Bus Machine ID" "$DBUS_ID_STATUS"
    printf "%-22s %-40s\n" "Persistent Mounts" "$CUSTOM_MOUNTS_STATUS"
fi

echo

printf "%-22s %-10s\n" "Passed Checks" "$PASS_COUNT"
printf "%-22s %-10s\n" "Information" "$INFO_COUNT"
printf "%-22s %-10s\n" "Warnings" "$WARN_COUNT"
printf "%-22s %-10s\n" "Failed Checks" "$FAIL_COUNT"

# ------------------------------------------------------------
# Information, Warnings, and Failures
# ------------------------------------------------------------

if (( INFO_COUNT > 0 )); then

    echo
    echo "Information:"

    for item in "${INFO_MESSAGES[@]}"; do
        echo "  $INFO $item"
    done

fi

if (( WARN_COUNT > 0 )); then

    echo
    echo "Warnings:"

    for item in "${WARNINGS[@]}"; do
        echo "  $WARN $item"
    done

fi

if (( FAIL_COUNT > 0 )); then

    echo
    echo "Failed Checks:"

    for item in "${FAILURES[@]}"; do
        echo "  $FAIL $item"
    done

fi

# ------------------------------------------------------------
# Template Preparation Instructions
# ------------------------------------------------------------

if [[ "$TEMPLATE_MODE" == true && "$WARN_COUNT" -gt 0 ]]; then

    echo
    echo "Template Preparation:"
    echo
    echo "  For machine identity or SSH host key warnings:"
    echo
    echo "  1. Check the D-Bus machine ID:"
    echo "     ls -l /var/lib/dbus/machine-id"
    echo
    echo "     - Regular file: remove it during final preparation."
    echo "     - Symlink: leave it unchanged."
    echo
    echo "  2. Clear the system machine ID:"
    echo "     sudo truncate -s 0 /etc/machine-id"
    echo
    echo "  3. If the D-Bus machine ID is a regular file:"
    echo "     sudo rm -f /var/lib/dbus/machine-id"
    echo
    echo "  4. Remove existing SSH host keys:"
    echo "     sudo rm -f /etc/ssh/ssh_host_*"
    echo
    echo "  5. Shut down immediately:"
    echo "     sudo shutdown -h now"
    echo
    echo "  Do not boot the source VM again before converting it"
    echo "  to a template."

fi

# ------------------------------------------------------------
# Final Result
# ------------------------------------------------------------

echo
echo "========================================"

if (( FAIL_COUNT > 0 )); then

    echo " Overall Status: NOT READY"

    if [[ "$TEMPLATE_MODE" == true ]]; then
        echo " Resolve failed checks before template preparation."
    else
        echo " Resolve failed checks before considering the baseline complete."
    fi

    RESULT=2

elif (( WARN_COUNT > 0 )); then

    echo " Overall Status: READY WITH WARNINGS"

    if [[ "$TEMPLATE_MODE" == true ]]; then
        echo " Review warnings before final template preparation."
    else
        echo " Review warnings before considering the baseline complete."
    fi

    RESULT=1

else

    echo " Overall Status: PASS"

    if [[ "$TEMPLATE_MODE" == true ]]; then
        echo " Baseline and template readiness checks passed."
    else
        echo " Debian baseline checks passed."
    fi

    RESULT=0

fi

echo "========================================"

exit "$RESULT"
