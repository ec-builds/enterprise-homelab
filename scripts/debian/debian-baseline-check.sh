#!/bin/bash

# Debian Baseline & Template Readiness Check
# Performs non-destructive system validation with package metadata refresh.
#
# Default mode:
#   Validates the standard Debian baseline.
#
# Template mode:
#   Validates the Debian baseline plus template-specific readiness checks.
#
# Usage:
#   sudo bash debian-baseline-check.sh
#   sudo bash debian-baseline-check.sh --template
#   bash debian-baseline-check.sh --help

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
    echo "[PASS] $1"
    ((PASS_COUNT++))
}

info() {
    echo "[INFO] $1"
    INFO_MESSAGES+=("$1")
    ((INFO_COUNT++))
}

warn() {
    echo "[WARN] $1"
    WARNINGS+=("$1")
    ((WARN_COUNT++))
}

fail() {
    echo "[FAIL] $1"
    FAILURES+=("$1")
    ((FAIL_COUNT++))
}

section() {
    echo
    echo "========================================"
    echo " $1"
    echo "========================================"
}

# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

echo "========================================"

if [[ "$TEMPLATE_MODE" == true ]]; then
    echo " Debian Baseline & Template Readiness Check"
    echo " Mode: Template"
else
    echo " Debian Baseline Check"
    echo " Mode: Baseline"
fi

echo "========================================"

# ------------------------------------------------------------
# Operating System
# ------------------------------------------------------------

section "Operating System"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release

    if [[ "$ID" == "debian" ]]; then
        pass "Debian detected: $PRETTY_NAME"
    else
        fail "System is not Debian"
    fi

    if [[ "$VERSION_ID" == "13" ]]; then
        pass "Debian 13 detected"
    else
        warn "Expected Debian 13; detected version ${VERSION_ID:-unknown}"
    fi
else
    fail "/etc/os-release not found"
fi

ARCH="$(uname -m)"

if [[ "$ARCH" == "x86_64" ]]; then
    pass "Architecture: x86_64"
else
    warn "Unexpected architecture: $ARCH"
fi

# ------------------------------------------------------------
# System Identity
# ------------------------------------------------------------

section "System Identity"

HOSTNAME_CURRENT="$(hostname)"

if [[ -n "$HOSTNAME_CURRENT" ]]; then
    pass "Hostname configured: $HOSTNAME_CURRENT"
else
    fail "Hostname not configured"
fi

if hostnamectl >/dev/null 2>&1; then
    pass "hostnamectl is functional"
else
    fail "hostnamectl failed"
fi

# ------------------------------------------------------------
# Baseline Packages
# ------------------------------------------------------------

section "Baseline Packages"

BASELINE_PACKAGES=(
    vim
    git
    curl
    wget
    htop
    tree
    bash-completion
    cifs-utils
    rsync
    unzip
    ncdu
    smartmontools
    ca-certificates
)

for package in "${BASELINE_PACKAGES[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null \
        | grep -q "install ok installed"; then
        pass "$package installed"
    else
        fail "$package not installed"
    fi
done

# dnsutils is provided by bind9-dnsutils on Debian 13.
# Validate the required DNS troubleshooting capability instead
# of checking for a package literally named "dnsutils".

if command -v dig >/dev/null 2>&1; then
    pass "DNS utilities installed (dig available)"
else
    fail "DNS utilities not installed (dig unavailable)"
fi

# ------------------------------------------------------------
# Administrative Access
# ------------------------------------------------------------

section "Administrative Access"

if dpkg-query -W -f='${Status}' sudo 2>/dev/null \
    | grep -q "install ok installed"; then
    pass "sudo installed"
else
    fail "sudo not installed"
fi

# ------------------------------------------------------------
# SSH
# ------------------------------------------------------------

section "SSH"

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

# ------------------------------------------------------------
# Proxmox Guest Integration
# ------------------------------------------------------------

section "Proxmox Guest Integration"

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

# ------------------------------------------------------------
# Optional Services
# ------------------------------------------------------------

section "Optional Services"

# Avahi provides mDNS/local service discovery.
# It is optional and intentionally not included in the base template.
# Its absence is informational and does not affect readiness.

if dpkg-query -W -f='${Status}' avahi-daemon 2>/dev/null \
    | grep -q "install ok installed"; then

    info "Avahi installed (optional; not required by template)"

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

# ------------------------------------------------------------
# Networking
# ------------------------------------------------------------

section "Networking"

if ip -4 addr show scope global 2>/dev/null | grep -q 'inet '; then
    pass "Active IPv4 network interface detected"
else
    fail "No active IPv4 network interface detected"
fi

if ip route | grep -q '^default '; then
    pass "Default route configured"
else
    fail "Default route not configured"
fi

if getent hosts debian.org >/dev/null 2>&1; then
    pass "DNS resolution working"
else
    fail "DNS resolution failed"
fi

if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
    pass "External IP connectivity working"
else
    fail "External IP connectivity failed"
fi

# ------------------------------------------------------------
# Package Updates
# ------------------------------------------------------------

section "Package Updates"

if apt-get update -qq >/dev/null 2>&1; then
    pass "Debian repositories reachable"
else
    fail "Unable to reach Debian repositories"
fi

UPGRADE_COUNT="$(
    apt-get -s upgrade 2>/dev/null \
        | awk '/^[0-9]+ upgraded/ {print $1}'
)"

if [[ "${UPGRADE_COUNT:-0}" -eq 0 ]]; then
    pass "No pending package upgrades"
else
    warn "$UPGRADE_COUNT package upgrade(s) pending"
fi

# ------------------------------------------------------------
# Time Synchronization
# ------------------------------------------------------------

section "Time Synchronization"

if timedatectl show -p NTPSynchronized --value 2>/dev/null \
    | grep -q '^yes$'; then
    pass "System clock synchronized"
else
    warn "System clock not synchronized"
fi

# ------------------------------------------------------------
# Storage
# ------------------------------------------------------------

section "Storage"

ROOT_USAGE="$(
    df -P / \
        | awk 'NR==2 {gsub("%","",$5); print $5}'
)"

if [[ "$ROOT_USAGE" =~ ^[0-9]+$ ]]; then
    if (( ROOT_USAGE < 90 )); then
        pass "Root filesystem usage: ${ROOT_USAGE}%"
    else
        warn "Root filesystem usage high: ${ROOT_USAGE}%"
    fi
else
    warn "Unable to determine root filesystem usage"
fi

# ------------------------------------------------------------
# System Health
# ------------------------------------------------------------

section "System Health"

FAILED_UNITS="$(
    systemctl --failed --no-legend 2>/dev/null \
        | grep -c '[^[:space:]]' || true
)"

if [[ "$FAILED_UNITS" -eq 0 ]]; then
    pass "No failed systemd units"
else
    fail "$FAILED_UNITS failed systemd unit(s) detected"
fi

# Template warnings indicate machine-specific identity that should be cleared
# immediately before shutdown and conversion to a template. Clear /etc/machine-id
# with `truncate -s 0`, remove the existing SSH host keys, and check
# /var/lib/dbus/machine-id with `ls -l` before removing it. If the D-Bus
# machine-id is a symlink to /etc/machine-id, leave the symlink intact; if it is
# a regular file, remove it. This prevents cloned VMs from inheriting the same
# machine identity or SSH host keys. Shut down immediately after cleanup and do
# not boot the source VM again before converting it to a template.
#
# Commands:
#   sudo truncate -s 0 /etc/machine-id
#   ls -l /var/lib/dbus/machine-id
#   if [[ ! -L /var/lib/dbus/machine-id ]]; then
#       sudo rm -f /var/lib/dbus/machine-id
#   fi
#   sudo rm -f /etc/ssh/ssh_host_*
#   sudo shutdown -h now

# ------------------------------------------------------------
# Template Readiness
# ------------------------------------------------------------

if [[ "$TEMPLATE_MODE" == true ]]; then

    section "Template Readiness"

    if [[ -s /etc/machine-id ]]; then
        warn "/etc/machine-id is populated — clear during final template preparation"
    else
        pass "/etc/machine-id already cleared"
    fi

    if compgen -G "/etc/ssh/ssh_host_*" >/dev/null; then
        warn "SSH host keys exist — remove during final template preparation"
    else
        pass "SSH host keys cleared"
    fi

    if [[ -s /var/lib/dbus/machine-id ]]; then
        warn "/var/lib/dbus/machine-id contains machine-specific state"
    else
        pass "/var/lib/dbus/machine-id contains no machine-specific state"
    fi

    # Ignore expected Debian system mounts:
    #   /
    #   /boot
    #   /boot/efi
    #   swap
    #   installer CD-ROM mounts
    #
    # Any remaining entries may represent workload-specific,
    # network, or additional persistent storage.

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
        warn "Additional persistent mounts found in /etc/fstab"
        echo
        echo "$CUSTOM_MOUNTS"
    else
        pass "No additional persistent mounts found"
    fi

fi

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

section "Summary"

if [[ "$TEMPLATE_MODE" == true ]]; then
    echo "Mode: Template"
else
    echo "Mode: Baseline"
fi

echo
echo "PASS: $PASS_COUNT"
echo "INFO: $INFO_COUNT"
echo "WARN: $WARN_COUNT"
echo "FAIL: $FAIL_COUNT"

if (( INFO_COUNT > 0 )); then
    echo
    echo "Information:"
    for item in "${INFO_MESSAGES[@]}"; do
        echo "  [INFO] $item"
    done
fi

if (( WARN_COUNT > 0 )); then
    echo
    echo "Warnings:"
    for item in "${WARNINGS[@]}"; do
        echo "  [WARN] $item"
    done
fi

if (( FAIL_COUNT > 0 )); then
    echo
    echo "Failed Checks:"
    for item in "${FAILURES[@]}"; do
        echo "  [FAIL] $item"
    done
fi

echo

if (( FAIL_COUNT > 0 )); then
    echo "RESULT: NOT READY"

    if [[ "$TEMPLATE_MODE" == true ]]; then
        echo "Resolve failed checks before preparing the VM as a template."
    else
        echo "Resolve failed checks before considering the Debian baseline complete."
    fi

    exit 2

elif (( WARN_COUNT > 0 )); then
    echo "RESULT: READY WITH WARNINGS"

    if [[ "$TEMPLATE_MODE" == true ]]; then
        echo "Review warnings before final template preparation."

        echo
        echo "Template Preparation:"
        echo "  If the warnings are related to machine identity or SSH host keys:"
        echo
        echo "  1. Check whether the D-Bus machine ID is a symlink:"
        echo "     ls -l /var/lib/dbus/machine-id"
        echo
        echo "  2. Clear the system machine ID:"
        echo "     sudo truncate -s 0 /etc/machine-id"
        echo
        echo "  3. If /var/lib/dbus/machine-id is a regular file, remove it."
        echo "     If it is a symlink to /etc/machine-id, leave the symlink intact."
        echo "     if [[ ! -L /var/lib/dbus/machine-id ]]; then"
        echo "         sudo rm -f /var/lib/dbus/machine-id"
        echo "     fi"
        echo
        echo "  4. Remove existing SSH host keys:"
        echo "     sudo rm -f /etc/ssh/ssh_host_*"
        echo
        echo "  5. Shut down immediately:"
        echo "     sudo shutdown -h now"
        echo
        echo "  These steps prevent cloned VMs from inheriting the same machine"
        echo "  identity or SSH host keys. Do not boot the source VM again before"
        echo "  converting it to a template."
    else
        echo "Review warnings before considering the Debian baseline complete."
    fi

    exit 1

else
    echo "RESULT: READY"

    if [[ "$TEMPLATE_MODE" == true ]]; then
        echo "Baseline and template readiness checks passed."
    else
        echo "Debian baseline checks passed."
    fi

    exit 0
fi
