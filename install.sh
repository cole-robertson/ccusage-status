#!/bin/bash
# Install ccusage-status
# One-liner: curl -fsSL https://raw.githubusercontent.com/cole-robertson/ccusage-status/main/install.sh | bash

set -e

echo "Installing ccusage-status..."

# Check dependencies
missing=()
command -v jq >/dev/null || missing+=("jq")
command -v node >/dev/null || missing+=("node")

if [ ${#missing[@]} -ne 0 ]; then
    echo "Error: Missing dependencies: ${missing[*]}"
    echo ""
    echo "Install them with:"
    [ " ${missing[@]} " =~ " jq " ] && echo "  sudo apt install jq    # Debian/Ubuntu"
    [ " ${missing[@]} " =~ " node " ] && echo "  curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz | sudo tar -xJ -C /usr/local --strip-components=1"
    exit 1
fi

# Download and install
echo "Downloading..."
sudo curl -fsSL https://raw.githubusercontent.com/cole-robertson/ccusage-status/main/ccusage-status -o /usr/local/bin/ccusage-status
sudo chmod +x /usr/local/bin/ccusage-status

echo "✓ Installed to /usr/local/bin/ccusage-status"
echo ""

# Check if we should auto-configure waybar
if [ "$1" = "--waybar" ] || [ "$1" = "-w" ]; then
    echo "Setting up waybar configuration..."
    curl -fsSL https://raw.githubusercontent.com/cole-robertson/ccusage-status/main/setup-waybar.sh | bash
else
    echo "Add to your status bar:"
    echo ""
    echo "Waybar (or use --waybar flag to auto-configure):"
    echo '  "custom/ccusage": {'
    echo '    "format": "󰚩 {text}",'
    echo '    "return-type": "json",'
    echo '    "interval": 10,'
    echo '    "exec": "ccusage-status",'
    echo '    "tooltip": true'
    echo '  }'
    echo ""
    echo "See https://github.com/cole-robertson/ccusage-status for Polybar, i3blocks, etc."
fi