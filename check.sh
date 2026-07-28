#!/bin/bash

set -euo pipefail

readonly repo_root="$(cd "$(dirname "$0")" && pwd)"
readonly app="$repo_root/build/KeepAgentAwake.app"
readonly executable="$app/Contents/MacOS/KeepAgentAwake"
readonly info_plist="$app/Contents/Info.plist"

(
    cd "$repo_root"
    ./build.sh
)

/usr/bin/plutil -lint "$info_plist" >/dev/null
/usr/bin/codesign --verify --deep --strict "$app"
/usr/bin/python3 "$repo_root/tests/check_localizations.py"

plist_min=$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$info_plist")
binary_min=$(/usr/bin/xcrun vtool -show-build "$executable" |
    /usr/bin/awk '/minos/ { print $2; exit }')

[[ -n "$binary_min" ]] || {
    echo "Unable to read the binary deployment target." >&2
    exit 1
}

[[ "$binary_min" == "$plist_min" ]] || {
    echo "Deployment target mismatch: Info.plist=$plist_min, binary=$binary_min" >&2
    exit 1
}

echo "Checks passed: macOS deployment target $binary_min"
