#!/usr/bin/with-contenv bash

# LSIO Docker Mod: Emby.CustomCssJS
# Installs the CustomCssJS plugin DLL, JS module, and patches app.js
# Also patches apploader.js and index.html to bust browser cache
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
    cp "$APPJS" "${APPJS}.bak"
    sed -i 's|Promise\.all(list\.map(loadPlugin))|list.push("./modules/CustomCssJS.js"),Promise.all(list.map(loadPlugin))|' "$APPJS"
    echo "[customcssjs] app.js patched to load CustomCssJS module"
  else
    echo "[customcssjs] app.js already patched, skipping"
  fi
else
  echo "[customcssjs] WARNING: app.js not found at $APPJS"
fi

# 4. Patch apploader.js to not override urlCacheParam if already set
APPLOADER="/app/emby/system/dashboard-ui/apploader.js"
if [ -f "$APPLOADER" ]; then
  if ! grep -q "urlCacheParam||" "$APPLOADER"; then
    sed -i 's|docElem?globalThis.urlCacheParam="v="+docElem:appMode||(globalThis.urlCacheParam="v="+Date.now())|globalThis.urlCacheParam||(docElem?globalThis.urlCacheParam="v="+docElem:appMode||(globalThis.urlCacheParam="v="+Date.now()))|' "$APPLOADER"
    echo "[customcssjs] apploader.js patched for cache busting"
  else
    echo "[customcssjs] apploader.js already patched, skipping"
  fi
else
  echo "[customcssjs] WARNING: apploader.js not found at $APPLOADER"
fi

# 5. Patch index.html to set a unique cache param before apploader loads
INDEXHTML="/app/emby/system/dashboard-ui/index.html"
if [ -f "$INDEXHTML" ]; then
  if ! grep -q "urlCacheParam.*Date.now" "$INDEXHTML"; then
    sed -i 's|<script src="apploader.js" defer></script>|<script>globalThis.urlCacheParam="v="+Date.now()+"-c3";</script>\n    <script src="apploader.js?nocache3" defer></script>|' "$INDEXHTML"
    echo "[customcssjs] index.html patched for cache busting"
  else
    echo "[customcssjs] index.html already patched, skipping"
  fi
else
  echo "[customcssjs] WARNING: index.html not found at $INDEXHTML"
fi

echo "[customcssjs] Setup complete."
