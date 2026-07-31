#!/usr/bin/env bash
set -e

APP_ID="clownword-desert"

rm -rf "$HOME/.local/share/$APP_ID"
rm -rf "$HOME/.local/share/${APP_ID}-browser"
rm -f "$HOME/.local/bin/$APP_ID"
rm -f "$HOME/.local/share/applications/${APP_ID}.desktop"

if [[ -d "$HOME/Desktop" ]]; then
    rm -f "$HOME/Desktop/${APP_ID}.desktop"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

rm -f "$HOME/.local/bin/${APP_ID}-uninstall"

echo "ClownWord Desert has been uninstalled."
