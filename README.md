# Antigravity Battery Fix for macOS

Fix the extreme battery drain caused by Google Antigravity IDE on Mac.

## The Problem

Google Antigravity (the VS Code fork) ships with GPU acceleration disabled by default on macOS. This causes:

- **CPU usage of 90-100%** from the renderer process
- **Massive battery drain** (500+ energy impact over 12 hours)
- Fan noise and heat
- Reduced battery life from 6-7 hours to 3-4 hours

## The Solution

Launch Antigravity with GPU acceleration flags enabled:

```bash
open -a "Antigravity" --args \
  --disable-gpu-driver-bug-workarounds \
  --ignore-gpu-blacklist \
  --enable-gpu-rasterization \
  --enable-zero-copy \
  --enable-native-gpu-memory-buffers
```

## Results

| Metric | Before Fix | After Fix |
|--------|-----------|-----------|
| CPU Usage | **96%** | **~1-2%** |
| Energy Impact | 100+ | ~1 |
| 12hr Power | 500+ | <50 |

## Installation

### Option 1: Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/kim-el/antigravity-battery-fix/main/install.sh | bash
```

Then use `AntigravityOptimized.app` from your Desktop (drag it to your Dock).

### Option 2: Manual Install

1. **Clone this repo:**
   ```bash
   git clone https://github.com/kim-el/antigravity-battery-fix.git
   cd antigravity-battery-fix
   ```

2. **Run the install script:**
   ```bash
   ./install.sh
   ```

3. **Replace your Dock icon:**
   - Remove the original Antigravity from your Dock
   - Drag `AntigravityOptimized.app` from your Desktop to the Dock

### Option 3: Terminal Only

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
alias antigravity='open -a "Antigravity" --args --disable-gpu-driver-bug-workarounds --ignore-gpu-blacklist --enable-gpu-rasterization --enable-zero-copy --enable-native-gpu-memory-buffers'
```

Then always launch from terminal with: `antigravity`

## Verifying the Fix

1. Open **Activity Monitor** → **Energy** tab
2. Look at the **Energy Impact** column (not "12 hr Power")
3. Antigravity processes should show low numbers (under 10)

Or run:
```bash
ps aux | grep "[A]ntigravity" | awk '{sum += $3} END {print "Total CPU: " sum "%"}'
```

Should show ~1-3% instead of 90%+.

## Why This Happens

Antigravity is built on Electron (Chromium). By default, it uses conservative GPU settings for compatibility. On macOS (especially Apple Silicon), this causes the app to fall back to CPU-based rendering, which is extremely inefficient.

The flags we add:
- `--disable-gpu-driver-bug-workarounds` - Disables workarounds that may cause CPU fallback
- `--ignore-gpu-blacklist` - Forces GPU usage even if the GPU is "blacklisted"
- `--enable-gpu-rasterization` - Uses GPU for page rasterization
- `--enable-zero-copy` - Reduces memory copies between CPU and GPU
- `--enable-native-gpu-memory-buffers` - Uses native GPU memory buffers

## Tested On

- macOS Sequoia 15.x
- macOS Sonoma 14.x
- Apple Silicon (M1/M2/M3/M4)
- Antigravity 1.104.0

## Contributing

If you find additional flags that help, or if this fix works on Intel Macs, please open an issue or PR!

## Disclaimer

This is a community workaround. Google should fix this in Antigravity itself. Until then, this fix helps preserve your battery life.

## License

MIT
