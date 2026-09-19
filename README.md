# Agri-Sorter Mobile

Aplikasi Flutter offline untuk sortir komoditas pertanian.

## Build APK

Build release APK:

```bash
ANDROID_HOME=/tmp/android-sdk \
ANDROID_SDK_ROOT=/tmp/android-sdk \
JAVA_HOME=/usr/local/sdkman/candidates/java/21.0.12+1-ms \
PATH=/usr/local/sdkman/candidates/java/21.0.12+1-ms/bin:$PATH \
/tmp/flutter_sdk/bin/flutter build apk --release
```

Hasil build tersedia di:

`build/app/outputs/flutter-apk/app-release.apk`

Konfigurasi Gradle menggunakan heap yang dibatasi di `android/gradle.properties` agar build stabil di development container.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
