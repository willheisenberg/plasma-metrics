#!/usr/bin/env bash
set -e

echo "📊 System Metrics – Plasma 6 Widget Installer"
echo "==============================================="
echo

# --- Locate script directory ---
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLASMOID_DIR="$DIR/plasmoid"

# --- Sanity checks ---
if [ ! -d "$PLASMOID_DIR" ]; then
    echo "❌ plasmoid/ directory not found in $DIR"
    exit 1
fi

if ! command -v kpackagetool6 &>/dev/null; then
    echo "❌ kpackagetool6 not found. Please install plasma-sdk:"
    echo "   sudo pacman -S plasma-sdk   (Arch)"
    echo "   sudo apt install plasma-sdk (Debian/Ubuntu)"
    exit 1
fi

WIDGET_ID="com.github.willheisenberg.systemmetrics"

# --- Make metrics script executable ---
chmod +x "$PLASMOID_DIR/contents/scripts/metrics.sh"

# --- Check if already installed ---
if kpackagetool6 -t Plasma/Applet -s "$WIDGET_ID" &>/dev/null; then
    echo "🔄 Widget already installed. Upgrading..."
    echo
    kpackagetool6 -t Plasma/Applet -u "$PLASMOID_DIR"
else
    echo "📦 Installing widget..."
    echo
    kpackagetool6 -t Plasma/Applet -i "$PLASMOID_DIR"
fi

echo
echo "✅ Installation complete!"
echo
echo "Widget ID: $WIDGET_ID"
echo
echo "Next steps:"
echo "  1. Right-click your Plasma panel → 'Add Widgets...'"
echo "  2. Search for 'System Metrics'"
echo "  3. Drag it to your panel"
echo "  4. Right-click the widget → 'Configure...' to customize"
echo
echo "To test without adding to panel:"
echo "  plasmawindowed $WIDGET_ID"
echo
echo "To uninstall:"
echo "  kpackagetool6 -t Plasma/Applet -r $WIDGET_ID"
echo

# --- Check optional dependencies ---
echo "📋 Optional dependencies check:"
if command -v sensors &>/dev/null; then
    echo "  ✅ lm_sensors (CPU temperature)"
else
    echo "  ⚠️  lm_sensors not found – CPU temperature may be inaccurate"
    echo "     Install: sudo pacman -S lm_sensors"
fi

if command -v nvidia-smi &>/dev/null; then
    echo "  ✅ nvidia-smi (NVIDIA GPU monitoring)"
else
    echo "  ℹ️  nvidia-smi not found – OK if you don't have an NVIDIA GPU"
fi
echo
