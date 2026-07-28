#!/bin/bash
# 构建 KeepAgentAwake（SwiftUI 窗口 + 菜单栏 + App 图标）

set -e

echo "🔨 开始构建 KeepAgentAwake…"

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

echo "📦 编译 Swift…"
swiftc -O -o "$MACOS_DIR/$APP_NAME" \
    -target "$TARGET_ARCH-apple-macos$DEPLOYMENT_TARGET" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework Combine \
    -framework UserNotifications \
    -framework IOKit \
    -parse-as-library \
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
    echo "✅ 构建完成！"
    echo "📍 应用位置: $APP_DIR"
    echo "📦 二进制大小: $SIZE"
    echo ""
    echo "🚀 运行: open \"$APP_DIR\""
else
    echo "❌ 构建失败！"
    exit 1
fi
