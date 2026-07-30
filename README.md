<div align="center">

<img src="assets/readme-icon.png" width="128" height="128" alt="KeepAgentAwake app icon" />

<h1>KeepAgentAwake</h1>

### Keep your Mac awake while it works — but still let the screen go dark to save power.

English · [简体中文](README_zh.md)

[![Platform](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)](https://github.com/toddwyl/KeepAgentAwake/releases)
[![Built with](https://img.shields.io/badge/Swift%20%2F%20SwiftUI-orange?logo=swift&logoColor=white)](KeepAgentAwakeMain.swift)
[![Release](https://img.shields.io/github/v/release/toddwyl/KeepAgentAwake)](https://github.com/toddwyl/KeepAgentAwake/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/toddwyl/KeepAgentAwake/total)](https://github.com/toddwyl/KeepAgentAwake/releases)
[![Stars](https://img.shields.io/github/stars/toddwyl/KeepAgentAwake?style=flat)](https://github.com/toddwyl/KeepAgentAwake/stargazers)

[Overview](#overview) · [How it works](#how-it-works) · [Download](#download) · [Features](#features) · [Building from source](#building-from-source) · [Star History](#star-history)

</div>

---

## Overview

`KeepAgentAwake` is a native Swift / SwiftUI **menu bar app** that stops your Mac from falling asleep while a long-running task is in flight — a download, a build, an AI agent grinding through a task list, a demo — **without** keeping the display at full brightness the whole time.

It lives entirely in the menu bar (`LSUIElement`, no Dock icon) and gives you a single **“never sleep”** toggle plus an optional settings window. The point is the balance: **the system stays awake, but the screen can still turn off when you walk away**, so you don't burn the panel or the battery for nothing.

This is a small, focused utility — one toggle you'll actually use, not a control panel you have to learn.

## How it works

Two independent jobs, driven by one toggle: keep the **system** awake, while letting the **display** idle off.

```
       menu bar toggle  (⌘⇧P)
              │  ON
              ▼
   ┌───────────────────────┐   prevent idle      ┌────────────────────┐
   │  IOKit power assertion │ ─────────────────▶ │  system never       │
   │  + caffeinate          │   system sleep      │  sleeps             │
   └───────────────────────┘                     └────────────────────┘
              │
              │  idle ≥ N seconds  (optional)
              ▼
   ┌───────────────────────┐   display off only  ┌────────────────────┐
   │  idle monitor          │ ─────────────────▶ │  screen dark,       │
   │  (+ keyboard backlight)│   any input wakes   │  system keeps going │
   └───────────────────────┘                     └────────────────────┘
```

- **Stay awake** uses **IOKit power assertions** and `caffeinate` to block *idle system sleep*.
- **Idle display off** runs a lightweight idle monitor: after N seconds of no input it turns the display off (system keeps running); any keypress or click brings it back.
- **Lid-close** behavior is opt-in and goes through `pmset -a disablesleep`.

> [!NOTE]
> For lid options that use `pmset disablesleep`, an **administrator password is requested only when the system state must actually change** — the app reads the current `pmset` state first, then decides whether to elevate.

## Download

> [!TIP]
> The easiest way to install — no Xcode, no command line.

1. Grab the latest **`KeepAgentAwake.dmg`** from the [**Releases**](https://github.com/toddwyl/KeepAgentAwake/releases/latest) page.
2. Double-click the DMG and drag **KeepAgentAwake.app** into **Applications**.
3. Launch it — the icon appears in the menu bar. Press **⌘⇧P** (or click the icon) to toggle never-sleep.

A `KeepAgentAwake.app.zip` is also attached for anyone who prefers a plain archive.

> [!NOTE]
> The app is unsigned. On first launch macOS may warn it's from an unidentified developer — right-click the app and choose **Open**, or allow it under **System Settings → Privacy & Security**.

## Features

| Capability | Description |
|------------|-------------|
| **Never sleep** | Prevents **idle** system sleep; combine with “sleep display when idle” to avoid keeping the panel at full brightness. |
| **Idle display off** | After N seconds/minutes of no input, turn displays off (or set to “never”); any input keeps the screen on. |
| **Keyboard backlight** | Optionally simulates repeated “brightness down” keys when idle triggers display sleep (effect varies by hardware and OS). |
| **Lid / power** | Optional `pmset -a disablesleep` path for lid-close behavior (requires admin approval; see in-app text). |
| **Startup automation** | Optionally launch at login and enable Never Sleep when the app starts. Both settings default to off. |
| **Shortcuts** | **⌘⇧P** toggles never-sleep; **⌘⌃⎋** emergency-off while active. |
| **Menu bar** | **Left click:** if a main window exists, show/hide it; otherwise toggle never-sleep. **Right click:** menu. |

The status item reflects the current mode (e.g. system default vs never-sleep) and can show elapsed time.

## Requirements

- **macOS 13** or later (matches `LSMinimumSystemVersion` in `Info.plist`)
- **Xcode / Swift command-line tools** — only if you build from source

## Building from source

You need Swift and `swiftc` (Xcode Command Line Tools).

```bash
git clone https://github.com/toddwyl/KeepAgentAwake.git
cd KeepAgentAwake
chmod +x build.sh
./build.sh
```

The app bundle is written to `build/KeepAgentAwake.app`:

```bash
open build/KeepAgentAwake.app
```

You can copy `KeepAgentAwake.app` to `/Applications/` if you like.

> [!TIP]
> `build.sh` runs `tools/RenderAppIcon.swift` for the icon and compiles `KeepAgentAwakeMain.swift`, `KeepAgentAwakeViews.swift`, and `KeepAgentAwakeDelegate.swift`. No CocoaPods or SPM packages are required.

## Permissions & privacy

- **Automation / Apple Events**: Dimming keyboard backlight may trigger system prompts for controlling other apps or automation — follow what macOS shows.
- **Administrator password**: AppleScript elevation runs **only when** changing `disablesleep` (or similar) is required to match your settings; the app prefers reading power settings first.
- **Startup automation**: Launch-at-login uses `SMAppService.mainApp` on macOS 13+. Automatic protection startup does not change `pmset disablesleep`, so it does not unexpectedly show an administrator password prompt. Enable protection manually if lid-close prevention must also be changed.
- If you used the older **ScreenControl** build, the first launch **migrates** `ScreenControl.*` UserDefaults keys to `KeepAgentAwake.*` when the new key is missing, so preferences are preserved.

## Repository layout

```
KeepAgentAwake/
├── KeepAgentAwakeMain.swift      # SwiftUI @main entry
├── KeepAgentAwakeViews.swift     # Main window UI
├── KeepAgentAwakeDelegate.swift  # AppDelegate, power & menu bar
├── Info.plist
├── build.sh
├── tools/
│   └── RenderAppIcon.swift       # Generates AppIcon at build time
└── assets/
    └── readme-icon.png           # Icon used in README
```

## Uninstall

Remove `KeepAgentAwake.app` from Applications. If you granted Accessibility, Automation, or other permissions, revoke them under **System Settings → Privacy & Security** as needed.

## Star History

<a href="https://star-history.com/#toddwyl/KeepAgentAwake&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=toddwyl/KeepAgentAwake&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=toddwyl/KeepAgentAwake&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=toddwyl/KeepAgentAwake&type=Date" width="600" />
  </picture>
</a>
