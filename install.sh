#!/usr/bin/env bash
set -e

echo "📊 Plasma Command Output Metrics Installer"
echo "=========================================="
echo

# --- Locate script directory ---
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$DIR/profiles"

# --- Sanity check ---
if [ ! -d "$PROFILES_DIR" ]; then
    echo "❌ profiles/ directory not found."
    exit 1
fi

# --- Collect profiles ---
mapfile -t PROFILES < <(find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

if [ "${#PROFILES[@]}" -eq 0 ]; then
    echo "❌ No profiles found in profiles/."
    exit 1
fi

# --- Show selection ---
echo "Available hardware profiles:"
echo

i=1
for p in "${PROFILES[@]}"; do
    echo "  [$i] $p"
    ((i++))
done

echo
read -rp "Select profile [1-${#PROFILES[@]}]: " SELECTION

# --- Validate input ---
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || (( SELECTION < 1 || SELECTION > ${#PROFILES[@]} )); then
    echo "❌ Invalid selection."
    exit 1
fi

PROFILE="${PROFILES[$((SELECTION-1))]}"
PROFILE_DIR="$PROFILES_DIR/$PROFILE"

echo
echo "➡️ Selected profile: $PROFILE"
echo

# --- Install location ---
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# --- Install script ---
if [ ! -f "$PROFILE_DIR/metrics.sh" ]; then
    echo "❌ metrics.sh not found in $PROFILE_DIR"
    exit 1
fi

install -m 755 "$PROFILE_DIR/metrics.sh" "$INSTALL_DIR/plasma-metrics.sh"

# --- Done ---
echo "✅ Installation complete!"
echo
echo "Installed script:"
echo "  $INSTALL_DIR/plasma-metrics.sh"
echo
echo "Plasma setup:"
echo "  Command:        $INSTALL_DIR/plasma-metrics.sh"
echo "  Update interval: 1–2 seconds"
echo
echo "ℹ️ Make sure the Command Output widget is installed:"
echo "   https://github.com/Zren/plasma-applet-commandoutput"
echo
