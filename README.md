# Photo Edit Prompt Maker

An offline Android app (a WebView wrapper around one HTML page) that writes prompts for editing your own photos in ChatGPT, Gemini, Meta AI, Grok or another editor. Edit types: outfit, pose, outfit + pose, background, hairstyle, fix/enhance. It also lets you ask for a shape, pixel size and quality.

## What it is and is not
- Rule-based text builder. No AI, no accounts, no keys, no internet permission.
- It does not edit photos. Your photos never go through this app.
- Prompts cannot override an editor's safety rules or guarantee a result. Each editor decides what size and quality it really supports.
- The app page stores nothing (no localStorage, cookies or IndexedDB) and Android backup is off. The Copy button puts the prompt on your clipboard.

## Status
Beta. The APK is signed and package-checked (apksigner, aapt2) but has not been run on a real Android device by the author. Install, icon and the Copy button are unverified. Please open an issue if something breaks.

## Download
See Releases for a prebuilt APK (signed with the author's key).

## Use the page without Android
Open `assets/index.html` in any browser. It works offline.

## Build the APK
Needs JDK 17 and the Android SDK (build-tools 33.0.2, platform android-33). No Gradle.

    export ANDROID_SDK=/path/to/sdk
    export JAVA_HOME=/path/to/jdk17
    bash build.sh

Output: `build/EditPromptMaker.apk`. By default it signs with a throwaway debug key. To use your own key:

    KEYSTORE=/path/to/your.jks KEYSTORE_PASS=yourpass bash build.sh

An APK signed with a different key cannot update one signed with another key. Never commit a keystore.

## Layout
- `AndroidManifest.xml` - package com.instinct.editprompt, minSdk 24, no permissions
- `src/com/instinct/editprompt/MainActivity.java` - WebView plus a native clipboard bridge
- `assets/index.html` - the whole app
- `icons.txt` - launcher icons as base64 text (build.sh writes them to `res/`)
- `build.sh` - build script
