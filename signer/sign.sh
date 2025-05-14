#!/bin/bash

IPA="Walmart.ipa"
NEW_PROVISIONING_PROFILE="AROptical_Provisioning.mobileprovision"
SIGNED_IPA="SignedWalmart.ipa"
CERTIFICATE="Apple Distribution: Mikhail Safir (GAH72SPMY9)"

# Unzip IPA
unzip $IPA -d Payload

# Paths
APP_PATH="Payload/Payload/Walmart.app"
FRAMEWORKS_PATH="$APP_PATH/Frameworks"
PLUGINS_PATH="$APP_PATH/PlugIns"

# Replace provisioning profile in main app
cp $NEW_PROVISIONING_PROFILE "$APP_PATH/embedded.mobileprovision"

# Extract entitlements for main app
security cms -D -i $NEW_PROVISIONING_PROFILE > profile.plist
/usr/libexec/PlistBuddy -x -c 'Print :Entitlements' profile.plist > app_entitlements.plist

# Remove old code signatures
rm -rf "$APP_PATH/_CodeSignature"

# Sign each framework
if [ -d "$FRAMEWORKS_PATH" ]; then
  for FRAMEWORK in "$FRAMEWORKS_PATH"/*; do
    codesign -f -s "$CERTIFICATE" --entitlements app_entitlements.plist "$FRAMEWORK"
  done
fi

# Sign app extensions
if [ -d "$PLUGINS_PATH" ]; then
  for PLUGIN in "$PLUGINS_PATH"/*.appex; do
    cp $NEW_PROVISIONING_PROFILE "$PLUGIN/embedded.mobileprovision"
    
    # Extract extension entitlements (Optional: if another profile used)
    /usr/libexec/PlistBuddy -x -c 'Print :Entitlements' profile.plist > extension_entitlements.plist

    rm -rf "$PLUGIN/_CodeSignature"
    codesign -f -s "$CERTIFICATE" --entitlements extension_entitlements.plist "$PLUGIN"
  done
fi

# Sign the app
codesign -f -s "$CERTIFICATE" --entitlements app_entitlements.plist "$APP_PATH"

# Repack IPA
cd Payload
zip -r "../$SIGNED_IPA" *
cd ..

# Clean up
rm profile.plist app_entitlements.plist extension_entitlements.plist
rm -rf Payload

