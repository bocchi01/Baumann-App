#!/bin/zsh
# Signs the debug macOS build with custom entitlements to enable Keychain access without requiring a paid certificate.
set -euo pipefail

APP_PATH="build/macos/Build/Products/Debug/posture_app.app"
ENTITLEMENTS_TEMPLATE="macos/Runner/KeychainDebug.entitlements"
TEMP_ENTITLEMENTS="$(mktemp -t posture-app-entitlements).plist"

# Determine the keychain access group. Provide an overridable fallback so the script
# works even without a configured Apple Developer Team ID.
if [[ -n "${MACOS_TEAM_ID:-}" ]]; then
  KEYCHAIN_GROUP="${MACOS_TEAM_ID}.com.example.postureApp"
else
  echo "MACOS_TEAM_ID not set; using fallback keychain group 'com.example.postureApp'." >&2
  KEYCHAIN_GROUP="com.example.postureApp"
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle at $APP_PATH. Build the macOS target first (flutter run -d macos)." >&2
  exit 1
fi

# Generate a temporary entitlement file with the selected group and sign the app.
sed "s#__KEYCHAIN_GROUP__#${KEYCHAIN_GROUP}#" "$ENTITLEMENTS_TEMPLATE" > "$TEMP_ENTITLEMENTS"
codesign --force --entitlements "$TEMP_ENTITLEMENTS" --sign - "$APP_PATH"

rm "$TEMP_ENTITLEMENTS"
