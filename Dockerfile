# Reproducible Flutter/Dart Android toolchain for Mis Gastos.
# Flutter stable 3.47.5 / Dart 3.13.4 as recorded in the official release tracker
# https://github.com/flutter/flutter/issues/192828 and the Flutter SDK archive.
#
# This image intentionally does not include an Android emulator; it supports
# analyze, test, code generation, and APK build without host Flutter/Android SDK.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies required by Flutter, Android SDK, and native builds.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libglu1-mesa \
        openjdk-21-jdk \
        unzip \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Android SDK layout.
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Pinned Android command-line tools version.
# The "_latest" suffix in the filename is Google's naming convention; the
# version number below is fixed and verified before building this image.
ARG CMDLINE_TOOLS_VERSION=15859902
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && curl -fsSL \
        "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip" \
        -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# Pinned Android SDK components compatible with Flutter 3.47.5 defaults.
# Flutter 3.47.5 defaults: compileSdk 36, targetSdk 36, minSdk 24, NDK 28.2.13676358.
RUN yes | sdkmanager --licenses \
    && sdkmanager --install \
        "platform-tools" \
        "platforms;android-36" \
        "build-tools;36.0.0" \
        "ndk;28.2.13676358"

# Flutter SDK layout.
ENV FLUTTER_ROOT=/opt/flutter
ENV PATH=${PATH}:${FLUTTER_ROOT}/bin:${FLUTTER_ROOT}/bin/cache/dart-sdk/bin

# Pinned Flutter stable release downloaded from the official Flutter archive.
# The SHA-256 is verified against https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json.
ARG FLUTTER_VERSION=3.47.5
ARG FLUTTER_SHA256=2132e990f236f8d22e7c6314b29a191a95b10d7cbcfec9b4e2e303d996652cbb
ARG FLUTTER_ARCHIVE=flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
RUN curl -fsSL \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}" \
        -o /tmp/flutter.tar.xz \
    && echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum -c - \
    && tar -xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz \
    && git config --global --add safe.directory /opt/flutter \
    && flutter config --no-analytics \
    && flutter precache --android

WORKDIR /app
