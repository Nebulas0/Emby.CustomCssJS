#!/usr/bin/with-contenv bash

# LSIO Docker Mod: Emby.CustomCssJS
# Installs the CustomCssJS plugin DLL, JS module, and patches app.js
# Runs on every Emby container startup — idempotent and safe to re-run

echo "[customcssjs] Starting CustomCssJS mod setup..."

# 1. Copy plugin DLL to persistent config directory
if [ ! -f /config/plugins/Emby.CustomCssJS.dll ]; then
  cp /customcssjs/Emby.CustomCssJS.dll /config/plugins/
  chmod 755 /config/plugins/Emby.CustomCssJS.dll
  echo "[customcssjs] Plugin DLL installed to /config/plugins/"
else
  echo "[customcssjs] Plugin DLL already present, skipping"
fi

# 2. Copy JS module into Emby web UI
cp /customcssjs/CustomCssJS.js /app/emby/system/dashboard-ui/modules/CustomCssJS.js
echo "[customcssjs] JS module copied to dashboard-ui/modules/"

# 3. Patch app.js to load the module (idempotent)
APPJS="/app/emby/system/dashboard-ui/app.js"
if [ -f "$APPJS" ]; then
  if ! grep -q "CustomCssJS.js" "$APPJS"; then
    # Backup original
    cp "$APPJS" "${APPJS}.bak"
    # Insert module load before the plugin loading promise
    sed -i 's|Promise\.all(list\.map(loadPlugin))|list.push("./modules/CustomCssJS.js"),Promise.all(list.map(loadPlugin))|' "$APPJS"
    echo "[customcssjs] app.js patched to load CustomCssJS module"
  else
    echo "[customcssjs] app.js already patched, skipping"
  fi
else
  echo "[customcssjs] WARNING: app.js not found at $APPJS"
fi

echo "[customcssjs] Setup complete."
