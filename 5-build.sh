#!/usr/bin/env bash
# Builds Edit Prompt Maker into an installable APK with the plain Android SDK tools (no Gradle, no network at run time).
# Needs: JDK 17, Android SDK with build-tools 33.0.2 and platforms/android-33.
#   export ANDROID_SDK=/path/to/sdk ; export JAVA_HOME=/path/to/jdk17
# Signing: set KEYSTORE and KEYSTORE_PASS to use your own key. If KEYSTORE is not set,
# a throwaway debug key is generated in build/ (APKs signed with it cannot update an APK signed with another key).
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_SDK:?set ANDROID_SDK}"
: "${JAVA_HOME:?set JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"
BT="$ANDROID_SDK/build-tools/33.0.2"
AJ="$ANDROID_SDK/platforms/android-33/android.jar"
# Launcher icons are stored as base64 text in icons.txt and written to res/ here.
while read -r dir b64; do mkdir -p "res/$dir"; printf '%s' "$b64" | base64 -d > "res/$dir/ic_launcher.png"; done < icons.txt
OUT=build; rm -rf "$OUT"; mkdir -p "$OUT/compiled" "$OUT/gen" "$OUT/classes"
"$BT/aapt2" compile --dir res -o "$OUT/compiled"
"$BT/aapt2" link -o "$OUT/base.apk" -I "$AJ" --manifest AndroidManifest.xml -A assets \
  --java "$OUT/gen" --min-sdk-version 24 --target-sdk-version 33 "$OUT"/compiled/*.flat
javac --release 8 -cp "$AJ" -d "$OUT/classes" $(find src "$OUT/gen" -name '*.java')
"$BT/d8" --release --min-api 24 --lib "$AJ" --output "$OUT" $(find "$OUT/classes" -name '*.class')
cp "$OUT/base.apk" "$OUT/unsigned.apk"
zip -q -j "$OUT/unsigned.apk" "$OUT/classes.dex"
"$BT/zipalign" -f 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"
if [ -z "${KEYSTORE:-}" ]; then
  KEYSTORE="$OUT/debug.jks"; KEYSTORE_PASS="debugpass"
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KEYSTORE_PASS" -keypass "$KEYSTORE_PASS" \
    -alias key -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Debug" >/dev/null 2>&1
fi
export KSP="${KEYSTORE_PASS:?set KEYSTORE_PASS}"
"$BT/apksigner" sign --ks "$KEYSTORE" --ks-pass env:KSP --key-pass env:KSP --out "$OUT/EditPromptMaker.apk" "$OUT/aligned.apk"
"$BT/apksigner" verify "$OUT/EditPromptMaker.apk"
echo "Built $OUT/EditPromptMaker.apk"
