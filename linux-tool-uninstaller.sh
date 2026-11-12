
#!/bin/bash

set -u

# ==========================================
# Linux Tool Uninstaller
# Compatible with Kali Linux / Debian
# ==========================================

clear

echo "=========================================="
echo "       LINUX TOOL UNINSTALLER"
echo "=========================================="
echo

# Check root privileges
if [[ $EUID -ne 0 ]]; then
    echo "[!] Please run this script with sudo."
    echo "Usage: sudo bash linux-tool-uninstaller.sh"
    exit 1
fi

# Ask for package name
read -rp "[?] Enter the tool/package name: " TOOL

# Validate input
if [[ -z "$TOOL" ]]; then
    echo "[!] Package name cannot be empty."
    exit 1
fi

if [[ ! "$TOOL" =~ ^[a-zA-Z0-9][a-zA-Z0-9+.-]*$ ]]; then
    echo "[!] Invalid package name."
    exit 1
fi

echo
echo "[*] Checking package..."

# Check if package exists
if ! apt-cache show "$TOOL" >/dev/null 2>&1; then
    echo "[!] Package not found in APT repositories."
    exit 1
fi

# Check installation status
STATUS=$(dpkg-query -W -f='${db:Status-Status}' "$TOOL" 2>/dev/null || true)

if [[ "$STATUS" != "installed" ]]; then
    echo "[!] $TOOL is not installed."
    exit 1
fi

echo
echo "[+] Package found: $TOOL"
echo "[+] Status: $STATUS"

echo
echo "=========================================="
echo "        UNINSTALLATION SUMMARY"
echo "=========================================="
echo "Tool       : $TOOL"
echo "Operation  : APT PURGE"
echo "Cleanup    : APT AUTOREMOVE"
echo "=========================================="
echo

read -rp "[?] Do you want to continue? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "[!] Operation cancelled."
    exit 0
fi

echo
echo "[*] Uninstalling $TOOL..."

if ! apt-get purge -y -- "$TOOL"; then
    echo "[!] Uninstallation failed."
    exit 1
fi

echo
echo "[*] Cleaning unused dependencies..."

apt-get autoremove --purge -y

echo
echo "=========================================="
echo "[+] Uninstallation process completed!"
echo "=========================================="

# Final verification
if dpkg-query -W -f='${db:Status-Status}' "$TOOL" 2>/dev/null | grep -qx installed; then
    echo "[!] Package is still installed."
else
    echo "[+] $TOOL is no longer installed."
fi

echo
