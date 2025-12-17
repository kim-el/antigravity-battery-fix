#!/bin/bash

# Antigravity Battery Fix Installer
# https://github.com/kim-el/antigravity-battery-fix

set -e

echo "==================================="
echo "Antigravity Battery Fix Installer"
echo "==================================="
echo ""

# Check if Antigravity is installed
if [ ! -d "/Applications/Antigravity.app" ]; then
    echo "Error: Antigravity.app not found in /Applications"
    echo "Please install Antigravity first."
    exit 1
fi

echo "Found Antigravity.app"

# Create the AppleScript launcher
echo "Creating optimized launcher..."

SCRIPT_CONTENT='tell application "Antigravity" to quit
delay 1
do shell script "open -a '\''Antigravity'\'' --args --disable-gpu-driver-bug-workarounds --ignore-gpu-blacklist --enable-gpu-rasterization --enable-zero-copy --enable-native-gpu-memory-buffers"'

echo "$SCRIPT_CONTENT" > /tmp/antigravity_launcher.scpt

# Compile the AppleScript into an app
osacompile -o ~/Desktop/AntigravityOptimized.app /tmp/antigravity_launcher.scpt

# Clean up
rm /tmp/antigravity_launcher.scpt

echo ""
echo "Success! Created: ~/Desktop/AntigravityOptimized.app"
echo ""
echo "==================================="
echo "Next steps:"
echo "==================================="
echo "1. Remove the original Antigravity from your Dock"
echo "2. Drag AntigravityOptimized.app from Desktop to your Dock"
echo "3. Always launch Antigravity from that icon"
echo ""
echo "To verify the fix is working:"
echo "  - Open Activity Monitor → Energy tab"
echo "  - Check that Antigravity's Energy Impact is low (under 10)"
echo ""
echo "Enjoy your battery life!"
