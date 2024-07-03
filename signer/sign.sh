#!/bin/bash

# Variables
IPA="AROpticalDemoApp.ipa"
NEW_PROVISIONING_PROFILE="AROptical_Provisioning.mobileprovision"
SIGNED_IPA="SignedAROpticalDemoApp.ipa"
CERTIFICATE="Apple Distribution: Mikhail Safir (GAH72SPMY9)"

# Unzip IPA
unzip $IPA -d Payload

# Replace Provisioning Profile
cp $NEW_PROVISIONING_PROFILE Payload/Payload/AROpticalDemoApp.app/embedded.mobileprovision

# Extract entitlements
security cms -D -i $NEW_PROVISIONING_PROFILE > profile.plist
/usr/libexec/PlistBuddy -x -c 'Print :Entitlements' profile.plist > entitlements.plist

cp entitlements.plist Payload/Payload/AROpticalDemoApp.app/entitlements.plist
PATH_ENTITLEMENTS="Payload/Payload/AROpticalDemoApp.app/entitlements.plist"

# Remove existing code signature
rm -rf Payload/Payload/AROpticalDemoApp.app/_CodeSignature

# Sign each framework
FRAMEWORKS_PATH="Payload/Payload/AROpticalDemoApp.app/Frameworks"
for FRAMEWORK in "$FRAMEWORKS_PATH"/*; do
  codesign -f -s "$CERTIFICATE" --entitlements $PATH_ENTITLEMENTS "$FRAMEWORK"
done

# Re-sign the App
codesign -f -s "$CERTIFICATE" --entitlements $PATH_ENTITLEMENTS Payload/Payload/AROpticalDemoApp.app

# Repackage IPA
cd Payload
zip -r ../$SIGNED_IPA *

echo "Re-signed IPA created: $SIGNED_IPA"

rm ../profile.plist ../entitlements.plist


