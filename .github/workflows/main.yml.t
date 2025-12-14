name: Build Android APK (JDK 21)

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v5
      
      - name: Set up JDK 21
        uses: actions/setup-java@v5
        with:
          java-version: '21'
          distribution: 'temurin'
          # Caches Gradle dependencies for speed
          cache: 'gradle'
          # ... (After Set up JDK 21 step)

      # 4. CREATE DEBUG KEY: Manually generate the debug.keystore to satisfy Gradle's validation
      - name: Generate Dummy Debug Keystore
        run: |
          mkdir -p android/app
          keytool -genkey -v -keystore android/app/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
        shell: bash

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Clean and Build APK
        run: |
          flutter clean
          flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/*.apk
