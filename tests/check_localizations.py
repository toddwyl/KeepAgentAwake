#!/usr/bin/env python3

import json
import plistlib
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "build" / "KeepAgentAwake.app"
LOCALIZATIONS = ("en", "ko")
REQUIRED_KEYS = {
    "About KeepAgentAwake…",
    "Current Status",
    "Never Sleep",
    "Restore Normal",
    "Settings",
    "Quit KeepAgentAwake",
    "KeepAgentAwake Help",
    "Display turned off due to inactivity",
    "Never Sleep enabled",
    "Never Sleep disabled",
}
HAN = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff]")
STRING_LITERAL = re.compile(r'"""(.*?)"""|"(?:\\.|[^"\\])*"', re.DOTALL)
FORMAT_PLACEHOLDER = re.compile(r"%(?:\d+\$)?[@d]")


def load_strings(path: Path) -> dict[str, str]:
    result = subprocess.run(
        ["/usr/bin/plutil", "-convert", "json", "-o", "-", str(path)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def assert_no_han_in_swift_strings() -> None:
    for path in ROOT.glob("*.swift"):
        text = path.read_text(encoding="utf-8")
        for match in STRING_LITERAL.finditer(text):
            literal = match.group(0)
            assert not HAN.search(literal), (
                f"Chinese text remains in a Swift string literal: {path.name}: {literal[:80]}"
            )


def localization_keys_used_by_swift() -> set[str]:
    keys: set[str] = set()
    pattern = re.compile(r'trf?\("((?:\\.|[^"\\])*)"')
    for path in ROOT.glob("*.swift"):
        text = path.read_text(encoding="utf-8")
        for raw_key in pattern.findall(text):
            keys.add(json.loads(f'"{raw_key}"'))
    return keys


def main() -> None:
    with (ROOT / "Info.plist").open("rb") as handle:
        info = plistlib.load(handle)

    assert info["CFBundleDevelopmentRegion"] == "en"
    assert info["CFBundleLocalizations"] == list(LOCALIZATIONS)
    assert not HAN.search(info["NSAppleEventsUsageDescription"])

    tables: dict[str, dict[str, str]] = {}
    for language in LOCALIZATIONS:
        lproj = ROOT / "Resources" / f"{language}.lproj"
        localizable = lproj / "Localizable.strings"
        info_strings = lproj / "InfoPlist.strings"
        assert localizable.is_file(), f"Missing {localizable}"
        assert info_strings.is_file(), f"Missing {info_strings}"
        tables[language] = load_strings(localizable)
        load_strings(info_strings)

    assert set(tables["en"]) == set(tables["ko"]), "Localization key sets differ"
    assert REQUIRED_KEYS <= set(tables["en"]), "Required UI strings are missing"
    used_keys = localization_keys_used_by_swift()
    missing_keys = used_keys - set(tables["en"])
    assert not missing_keys, f"Swift uses missing localization keys: {sorted(missing_keys)}"
    assert all(key == value for key, value in tables["en"].items()), (
        "English must be the source/default language"
    )
    assert all(value.strip() for value in tables["ko"].values())
    assert tables["ko"]["Never Sleep"] == "잠자기 방지"
    for key, english in tables["en"].items():
        english_placeholders = FORMAT_PLACEHOLDER.findall(english)
        korean_placeholders = FORMAT_PLACEHOLDER.findall(tables["ko"][key])
        assert english_placeholders == korean_placeholders, (
            f"Format placeholders differ for {key!r}: "
            f"en={english_placeholders}, ko={korean_placeholders}"
        )

    assert_no_han_in_swift_strings()

    if APP.is_dir():
        for language in LOCALIZATIONS:
            built = APP / "Contents" / "Resources" / f"{language}.lproj"
            assert (built / "Localizable.strings").is_file(), (
                f"Built app is missing {language} Localizable.strings"
            )
            assert (built / "InfoPlist.strings").is_file(), (
                f"Built app is missing {language} InfoPlist.strings"
            )

    print("Localization checks passed: English default, Korean available")


if __name__ == "__main__":
    try:
        main()
    except (AssertionError, KeyError, subprocess.CalledProcessError) as error:
        print(f"Localization check failed: {error}", file=sys.stderr)
        raise SystemExit(1)
