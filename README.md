# Antigravity Battery & Performance Fix for macOS

Fix the extreme battery drain and memory issues caused by Google Antigravity IDE on Mac.

## The Problems

Google Antigravity (the VS Code fork) has several issues on macOS:

### 1. GPU Acceleration Disabled
- CPU usage of 90-100% from the renderer process
- Massive battery drain (500+ energy impact over 12 hours)
- Fan noise and heat
- Reduced battery life from 6-7 hours to 3-4 hours

### 2. Pyrefly Memory Leak 🆕
- The `meta.pyrefly` extension (Python type checker from Meta) has a severe memory leak
- Can consume **5-6GB+ of RAM** and keeps growing
- Respawns automatically after being killed
- Runs even if you never open a Python file

### 3. Auto-Installed Extensions 🆕
- Antigravity auto-installs language extensions (Java, PHP, Python, Go, Ruby, C++, etc.)
- Each extension runs a language server in the background **at launch**
- 17+ extensions = 30%+ constant background CPU usage even when idle

## The Solutions

### Solution 1: GPU Acceleration (Launch Wrapper)

Launch Antigravity with GPU acceleration flags enabled:

```bash
open -a "Antigravity" --args \
  --disable-gpu-driver-bug-workarounds \
  --ignore-gpu-blacklist \
  --enable-gpu-rasterization \
  --enable-zero-copy \
  --enable-native-gpu-memory-buffers
```

### Solution 2: Remove Pyrefly (Memory Leak Fix)

```bash
# Kill the process
pkill -9 pyrefly

# Remove the extension
rm -rf ~/.antigravity/extensions/meta.pyrefly-*

# Clean from registry
python3 << 'EOF'
import json
with open('$HOME/.antigravity/extensions/extensions.json', 'r') as f:
    data = json.load(f)
filtered = [e for e in data if 'pyrefly' not in e.get('identifier', {}).get('id', '').lower()]
with open('$HOME/.antigravity/extensions/extensions.json', 'w') as f:
    json.dump(filtered, f)
EOF
```

### Solution 3: Remove All Auto-Installed Extensions

Nuclear option for maximum battery savings:

```bash
# Remove all extension folders
rm -rf ~/.antigravity/extensions/*/

# Reset extensions registry
echo '[]' > ~/.antigravity/extensions/extensions.json
```

Don't worry — extensions will be re-offered when you open relevant file types. You can install only what you need, when you need it.

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/kim-el/antigravity-battery-fix/main/install.sh | bash
```

Then use **AntigravityOptimized.app** from your Desktop (drag it to your Dock).

### Manual Install

1. Clone this repo:
```bash
git clone https://github.com/kim-el/antigravity-battery-fix.git
cd antigravity-battery-fix
```

2. Run the install script:
```bash
./install.sh
```

3. Replace your Dock icon:
   - Remove the original Antigravity from your Dock
   - Drag `AntigravityOptimized.app` from your Desktop to the Dock

## Results

| Metric | Before Fix | After Fix |
|--------|------------|-----------|
| Idle CPU Usage | 90%+ | 1-3% |
| RAM (Pyrefly leak) | 5GB+ | 0 |
| Background Extensions | 17 | 0 |
| Energy Impact | 100+ | <10 |
| 12hr Power | 500+ | <50 |
| Active CPU (chatting) | 95% | 15-40% |

## ⚠️ Important: How to Launch

**Always launch from AntigravityOptimized**, not the original Antigravity!

| Launch Method | GPU Flags? | Battery Efficient? |
|---------------|------------|-------------------|
| ✅ AntigravityOptimized.app | Yes | Yes |
| ✅ Spotlight → "AntigravityOptimized" | Yes | Yes |
| ❌ Spotlight → "Antigravity" | No | No |
| ❌ Original Dock icon | No | No |

The Dock will show "Antigravity" when the app is running — that's normal. What matters is **how you launch it**.

## Verifying the Fix

### Check GPU Flags Are Active
```bash
ps aux | grep "Antigravity.app/Contents/MacOS/Electron" | grep -v grep
```
Should show `--enable-gpu-rasterization --enable-zero-copy` etc.

### Check Pyrefly Is Gone
```bash
ps aux | grep pyrefly | grep -v grep
```
Should return nothing.

### Check CPU Usage
```bash
ps aux | grep "[A]ntigravity" | awk '{sum += $3} END {print "Total CPU: " sum "%"}'
```
Should show ~1-3% when idle, 15-40% when active.

### Check Extensions Are Removed
```bash
ls ~/.antigravity/extensions/ | grep -v extensions.json | wc -l
```
Should show 0 (or only extensions you explicitly installed).

### Check in Activity Monitor
1. Open Activity Monitor → CPU tab
2. Search for "Antigravity"
3. Look at "Antigravity Helper (Renderer)" — this is the main one to watch

## Tested On

- macOS Tahoe 26.1
- Apple M4
- Antigravity 1.11.17

Should work on other macOS versions and Apple Silicon chips. Please open an issue to report your results!

## Why This Happens

### GPU Issue
Antigravity is built on Electron (Chromium). By default, it uses conservative GPU settings for compatibility. On macOS (especially Apple Silicon), this causes the app to fall back to CPU-based rendering, which is extremely inefficient.

The flags we add:
- `--disable-gpu-driver-bug-workarounds` - Disables workarounds that may cause CPU fallback
- `--ignore-gpu-blacklist` - Forces GPU usage even if the GPU is "blacklisted"
- `--enable-gpu-rasterization` - Uses GPU for page rasterization
- `--enable-zero-copy` - Reduces memory copies between CPU and GPU
- `--enable-native-gpu-memory-buffers` - Uses native GPU memory buffers

### Pyrefly Memory Leak
Pyrefly is Meta's new Python type checker written in Rust. Version 0.46.0 has a memory leak that causes unbounded memory growth. It's bundled with Antigravity and starts automatically, even if you never open a Python file.

### Auto-Installed Extensions
Antigravity aggressively installs "recommended" extensions when it detects certain file types. Each language extension (Java, PHP, Python, etc.) runs its own language server process that consumes CPU and RAM constantly, not just when you're using that language.

## License

MIT
