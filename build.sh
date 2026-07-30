#!/bin/bash
# Build KeepAgentAwake (SwiftUI window + menu bar app)

set -e

echo "🔨 Building KeepAgentAwake…"

APP_NAME="KeepAgentAwake"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
DEPLOYMENT_TARGET=$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' Info.plist)
TARGET_ARCH=$(uname -m)

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
cp -RX Resources/en.lproj Resources/ko.lproj "$RESOURCES_DIR/"

echo "📦 Compiling Swift…"
swiftc -O -o "$MACOS_DIR/$APP_NAME" \
    -target "$TARGET_ARCH-apple-macos$DEPLOYMENT_TARGET" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework Combine \
    -framework UserNotifications \
    -framework IOKit \
    -parse-as-library \
    Localization.swift \
    KeepAgentAwakeMain.swift \
    KeepAgentAwakeViews.swift \
    KeepAgentAwakeDelegate.swift

cp -X Info.plist "$CONTENTS_DIR/"
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"
xattr -cr "$APP_DIR"
codesign --force --deep --sign - "$APP_DIR"

if [ -f "$MACOS_DIR/$APP_NAME" ]; then
    SIZE=$(du -h "$MACOS_DIR/$APP_NAME" | awk '{print $1}')
    echo ""
    echo "✅ Build complete"
    echo "📍 App: $APP_DIR"
    echo "📦 Binary size: $SIZE"
    echo ""
    echo "🚀 Run: open \"$APP_DIR\""
else
    echo "❌ Build failed"
    exit 1
fi
