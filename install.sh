#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ClownWord Desert"
APP_ID="clownword-desert"

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/$APP_ID"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
LAUNCHER="$BIN_DIR/$APP_ID"
UNINSTALLER="$BIN_DIR/${APP_ID}-uninstall"
DESKTOP_FILE="$APP_DIR/${APP_ID}.desktop"

if [[ ! -f "$SOURCE_DIR/index.html" ]]; then
    echo "ERROR: index.html was not found."
    echo "Run this installer from the ClownWord Desert folder."
    exit 1
fi

echo "Installing $APP_NAME..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Copy the application files without copying Git history.
tar \
    --exclude=".git" \
    --exclude="dist" \
    --exclude="install.sh" \
    --exclude="uninstall.sh" \
    -C "$SOURCE_DIR" \
    -cf - . |
tar -C "$INSTALL_DIR" -xf -

# Create an icon when the project does not already include one.
if [[ ! -f "$INSTALL_DIR/icon.svg" ]]; then
    cat > "$INSTALL_DIR/icon.svg" <<'ICON_EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="90" fill="#d28a2e"/>
  <path d="M100 360 256 80l156 280Z" fill="#ef476f"/>
  <path d="M165 360 256 80l91 280Z" fill="#fff1c9"/>
  <circle cx="256" cy="245" r="76" fill="#fff3df"/>
  <circle cx="226" cy="226" r="10" fill="#21150d"/>
  <circle cx="286" cy="226" r="10" fill="#21150d"/>
  <circle cx="256" cy="260" r="17" fill="#ef476f"/>
  <path d="M215 284q41 50 82 0" fill="none" stroke="#7f1d38"
        stroke-width="14" stroke-linecap="round"/>
  <text x="256" y="447" text-anchor="middle"
        font-family="sans-serif" font-size="68"
        font-weight="bold" fill="#21150d">SPELL</text>
</svg>
ICON_EOF
fi

# Application launcher. It prefers browser application mode.
cat > "$LAUNCHER" <<LAUNCHER_EOF
#!/usr/bin/env bash
set -e

GAME_FILE="$INSTALL_DIR/index.html"
GAME_URL="file://\$GAME_FILE"

if command -v google-chrome >/dev/null 2>&1; then
    exec google-chrome \
        --app="\$GAME_URL" \
        --class=clownword-desert \
        --user-data-dir="\$HOME/.local/share/clownword-desert-browser"
elif command -v google-chrome-stable >/dev/null 2>&1; then
    exec google-chrome-stable \
        --app="\$GAME_URL" \
        --class=clownword-desert \
        --user-data-dir="\$HOME/.local/share/clownword-desert-browser"
elif command -v chromium >/dev/null 2>&1; then
    exec chromium \
        --app="\$GAME_URL" \
        --class=clownword-desert \
        --user-data-dir="\$HOME/.local/share/clownword-desert-browser"
elif command -v chromium-browser >/dev/null 2>&1; then
    exec chromium-browser \
        --app="\$GAME_URL" \
        --class=clownword-desert \
        --user-data-dir="\$HOME/.local/share/clownword-desert-browser"
elif command -v brave-browser >/dev/null 2>&1; then
    exec brave-browser \
        --app="\$GAME_URL" \
        --class=clownword-desert \
        --user-data-dir="\$HOME/.local/share/clownword-desert-browser"
else
    exec xdg-open "\$GAME_FILE"
fi
LAUNCHER_EOF

chmod +x "$LAUNCHER"

# Desktop/menu application entry.
cat > "$DESKTOP_FILE" <<DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
GenericName=Sight Word Game
Comment=Spell sight words to defeat clown hordes in the desert
Exec=$LAUNCHER
Icon=$INSTALL_DIR/icon.svg
Terminal=false
Categories=Game;Education;
Keywords=spelling;sight words;education;game;clowns;desert;
StartupNotify=true
StartupWMClass=clownword-desert
DESKTOP_EOF

chmod +x "$DESKTOP_FILE"

# Standalone uninstaller command.
cat > "$UNINSTALLER" <<UNINSTALL_EOF
#!/usr/bin/env bash
set -e

APP_ID="$APP_ID"

rm -rf "\$HOME/.local/share/\$APP_ID"
rm -rf "\$HOME/.local/share/\${APP_ID}-browser"
rm -f "\$HOME/.local/bin/\$APP_ID"
rm -f "\$HOME/.local/share/applications/\${APP_ID}.desktop"

if [[ -d "\$HOME/Desktop" ]]; then
    rm -f "\$HOME/Desktop/\${APP_ID}.desktop"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "\$HOME/.local/share/applications" 2>/dev/null || true
fi

rm -f "\$HOME/.local/bin/\${APP_ID}-uninstall"

echo "ClownWord Desert has been uninstalled."
UNINSTALL_EOF

chmod +x "$UNINSTALLER"

# Also place a removable uninstall script in the project.
cp "$UNINSTALLER" "$SOURCE_DIR/uninstall.sh"
chmod +x "$SOURCE_DIR/uninstall.sh"

# Add an actual desktop shortcut when a Desktop directory exists.
if [[ -d "$HOME/Desktop" ]]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/${APP_ID}.desktop"
    chmod +x "$HOME/Desktop/${APP_ID}.desktop"

    if command -v gio >/dev/null 2>&1; then
        gio set "$HOME/Desktop/${APP_ID}.desktop" \
            metadata::trusted true 2>/dev/null || true
    fi
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" 2>/dev/null || true
fi

echo
echo "$APP_NAME installed successfully."
echo
echo "Launch from the application menu or run:"
echo "  clownword-desert"
echo
echo "Uninstall with:"
echo "  clownword-desert-uninstall"
