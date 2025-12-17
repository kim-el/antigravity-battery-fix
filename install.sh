#!/bin/bash

echo "🔧 Antigravity Battery & Performance Fix Installer"
echo "=================================================="
echo ""

# Step 1: Kill Pyrefly if running
echo "Step 1: Killing Pyrefly (memory leak fix)..."
pkill -9 pyrefly 2>/dev/null && echo "  ✅ Pyrefly killed" || echo "  ℹ️  Pyrefly not running"

# Step 2: Remove Pyrefly extension
echo "Step 2: Removing Pyrefly extension..."
rm -rf ~/.antigravity/extensions/meta.pyrefly-* 2>/dev/null && echo "  ✅ Pyrefly extension removed" || echo "  ℹ️  Pyrefly extension not found"

# Step 3: Ask about other extensions
echo ""
echo "Step 3: Extension cleanup"
EXTENSION_COUNT=$(ls ~/.antigravity/extensions/ 2>/dev/null | grep -v extensions.json | wc -l | tr -d ' ')
echo "  Found $EXTENSION_COUNT extensions installed."
echo ""
read -p "  Remove ALL extensions? (Recommended for max battery) [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  Removing all extensions..."
    rm -rf ~/.antigravity/extensions/*/ 2>/dev/null
    echo '[]' > ~/.antigravity/extensions/extensions.json
    echo "  ✅ All extensions removed"
else
    # Just clean Pyrefly from registry
    echo "  Keeping extensions, just cleaning Pyrefly from registry..."
    if [ -f ~/.antigravity/extensions/extensions.json ]; then
        python3 -c "
import json
with open('$HOME/.antigravity/extensions/extensions.json', 'r') as f:
    data = json.load(f)
filtered = [e for e in data if 'pyrefly' not in e.get('identifier', {}).get('id', '').lower()]
with open('$HOME/.antigravity/extensions/extensions.json', 'w') as f:
    json.dump(filtered, f)
" 2>/dev/null && echo "  ✅ Registry cleaned" || echo "  ⚠️  Could not clean registry"
    fi
fi

# Step 4: Create AntigravityOptimized.app
echo ""
echo "Step 4: Creating AntigravityOptimized.app..."

APP_PATH="$HOME/Desktop/AntigravityOptimized.app"
rm -rf "$APP_PATH" 2>/dev/null

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Create executable
cat > "$APP_PATH/Contents/MacOS/AntigravityOptimized" << 'SCRIPT'
#!/bin/bash
open -a "Antigravity" --args \
  --disable-gpu-driver-bug-workarounds \
  --ignore-gpu-blacklist \
  --enable-gpu-rasterization \
  --enable-zero-copy \
  --enable-native-gpu-memory-buffers
SCRIPT
chmod +x "$APP_PATH/Contents/MacOS/AntigravityOptimized"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AntigravityOptimized</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.antigravity-optimized</string>
    <key>CFBundleName</key>
    <string>AntigravityOptimized</string>
    <key>CFBundleDisplayName</key>
    <string>Antigravity Optimized</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>2.0</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

# Copy icon from Antigravity
cp /Applications/Antigravity.app/Contents/Resources/Antigravity.icns "$APP_PATH/Contents/Resources/AppIcon.icns" 2>/dev/null

# Refresh Spotlight
touch "$APP_PATH"
mdimport "$APP_PATH" 2>/dev/null

echo "  ✅ AntigravityOptimized.app created on Desktop"

# Done
echo ""
echo "=================================================="
echo "✅ Installation complete!"
echo ""
echo "🚀 How to use:"
echo "   1. Quit Antigravity if running (Cmd+Q)"
echo "   2. Launch 'AntigravityOptimized' from Desktop or Spotlight"
echo "   3. Drag it to your Dock for easy access"
echo ""
echo "⚠️  Remember: Always launch from AntigravityOptimized,"
echo "   not the original Antigravity app!"
echo ""
