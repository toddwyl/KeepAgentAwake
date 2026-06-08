<div align="center">

<img src="assets/readme-icon.png" width="128" height="128" alt="KeepAgentAwake 应用图标" />

<h1>KeepAgentAwake</h1>

### 让 Mac 在干活时保持清醒——但仍然允许屏幕熄灭省电。

[English](README.md) · 简体中文

[![Platform](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)](https://github.com/toddwyl/KeepAgentAwake/releases)
[![Built with](https://img.shields.io/badge/Swift%20%2F%20SwiftUI-orange?logo=swift&logoColor=white)](KeepAgentAwakeMain.swift)
[![Release](https://img.shields.io/github/v/release/toddwyl/KeepAgentAwake)](https://github.com/toddwyl/KeepAgentAwake/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/toddwyl/KeepAgentAwake/total)](https://github.com/toddwyl/KeepAgentAwake/releases)
[![Stars](https://img.shields.io/github/stars/toddwyl/KeepAgentAwake?style=flat)](https://github.com/toddwyl/KeepAgentAwake/stargazers)

[概览](#概览) · [工作原理](#工作原理) · [下载安装](#下载安装) · [功能](#功能) · [从源码构建](#从源码构建) · [Star History](#star-history)

</div>

---

## 概览

`KeepAgentAwake` 是一个原生 Swift / SwiftUI 的**菜单栏工具**：在长任务进行时阻止 Mac 自动睡眠——下载、编译、AI agent 跑任务清单、演示……——同时**不必**让屏幕全程保持高亮。

它完全驻留在菜单栏（`LSUIElement`，不占用 Dock），提供一个「**永不休眠**」开关与可选设置页。关键在于这个平衡：**系统保持清醒，而人离开后屏幕仍可自动关闭**，避免白白消耗屏幕寿命与电量。

这是一个小而专注的工具——一个你真的会用到的开关，而不是一堆需要学习的设置项。

## 工作原理

一个开关，两件独立的事：让**系统**保持清醒，同时允许**显示器**空闲熄屏。

```
        菜单栏开关  (⌘⇧P)
              │  开启
              ▼
   ┌───────────────────────┐   阻止空闲           ┌────────────────────┐
   │  IOKit 电源断言         │ ─────────────────▶ │  系统永不睡眠        │
   │  + caffeinate          │   系统睡眠           │                    │
   └───────────────────────┘                     └────────────────────┘
              │
              │  空闲 ≥ N 秒（可选）
              ▼
   ┌───────────────────────┐   仅关闭显示器       ┌────────────────────┐
   │  空闲监测               │ ─────────────────▶ │  屏幕熄灭，          │
   │  (+ 键盘背光)           │   任意输入即唤醒      │  系统继续运行        │
   └───────────────────────┘                     └────────────────────┘
```

- **永不休眠** 通过 **IOKit 电源断言** 和 `caffeinate` 阻止*空闲系统睡眠*。
- **空闲熄屏** 由一个轻量的空闲监测器驱动：无操作 N 秒后关闭显示器（系统照常运行），任意按键或点击即可唤醒。
- **合盖** 行为为可选项，通过 `pmset -a disablesleep` 实现。

> [!NOTE]
> 合盖相关选项若启用 `pmset disablesleep`，**仅在系统状态需要改变时**才会请求管理员密码——应用会先读取当前 `pmset` 状态，再决定是否提权执行。

## 下载安装

> [!TIP]
> 最简单的安装方式——无需 Xcode，无需命令行。

1. 从 [**Releases**](https://github.com/toddwyl/KeepAgentAwake/releases/latest) 页面下载最新的 **`KeepAgentAwake.dmg`**。
2. 双击 DMG，将 **KeepAgentAwake.app** 拖入 **应用程序** 文件夹。
3. 启动后，图标会出现在菜单栏。按 **⌘⇧P**（或点击图标）即可切换永不休眠。

如更习惯使用压缩包，Release 中也附带了 `KeepAgentAwake.app.zip`。

> [!NOTE]
> 应用未签名。首次启动时 macOS 可能提示「来自身份不明的开发者」——右键点击应用选择**打开**，或在 **系统设置 → 隐私与安全性** 中放行。

## 功能

| 能力 | 说明 |
|------|------|
| **永不休眠** | 防止系统因**空闲**进入睡眠；可与「空闲后熄屏」组合，避免屏幕长期保持高亮。 |
| **空闲熄屏** | 可设定空闲若干秒/分钟后关闭显示器（或设为「永不」）；有操作时保持亮屏。 |
| **键盘背光** | 在空闲触发熄屏时，可自动模拟多次「背光减小」键（效果因机型与系统策略而异）。 |
| **合盖电源** | 可选通过 `pmset -a disablesleep` 影响合盖行为（需管理员授权，详见应用内说明）。 |
| **快捷键** | **⌘⇧P** 切换永不休眠；**⌘⌃⎋** 在开启时紧急关闭永不休眠。 |
| **菜单栏** | 左键：若存在主窗口则在显示/隐藏主窗口间切换，否则切换永不休眠；右键打开菜单。 |

状态栏图标会随模式变化（例如「系统默认」与「永不休眠」等），并可选择在状态栏显示已运行时长。

## 系统要求

- **macOS 13** 或更高（与 `Info.plist` 中 `LSMinimumSystemVersion` 一致）
- **Xcode / Swift 命令行工具**——仅在从源码构建时需要

## 从源码构建

需要已安装 Swift 与 `swiftc`（Xcode Command Line Tools）。

```bash
git clone https://github.com/toddwyl/KeepAgentAwake.git
cd KeepAgentAwake
chmod +x build.sh
./build.sh
```

构建成功后，应用位于 `build/KeepAgentAwake.app`：

```bash
open build/KeepAgentAwake.app
```

也可将 `KeepAgentAwake.app` 拷贝到 `/Applications/` 使用。

> [!TIP]
> `build.sh` 会调用 `tools/RenderAppIcon.swift` 生成图标并编译 `KeepAgentAwakeMain.swift`、`KeepAgentAwakeViews.swift`、`KeepAgentAwakeDelegate.swift`，无需 CocoaPods / SPM 依赖。

## 权限与隐私

- **自动化 / Apple Events**：调暗键盘背光等功能可能触发系统对「控制其他应用」或相关自动化权限的提示，请以系统实际对话框为准。
- **管理员密码**：仅在为使系统 `disablesleep` 等状态与选项一致而**必须**修改时，通过 AppleScript 请求提权；应用会尽量先读取当前电源设置再决定是否弹窗。
- 若曾使用旧版 **ScreenControl**，首次启动会从 `ScreenControl.*` 的 UserDefaults 键**迁移**到 `KeepAgentAwake.*`（新键不存在时复制），避免丢失偏好设置。

## 仓库结构

```
KeepAgentAwake/
├── KeepAgentAwakeMain.swift      # SwiftUI @main 入口
├── KeepAgentAwakeViews.swift     # 主窗口界面
├── KeepAgentAwakeDelegate.swift  # AppDelegate、电源与菜单栏逻辑
├── Info.plist
├── build.sh
├── tools/
│   └── RenderAppIcon.swift       # 构建时生成 AppIcon
└── assets/
    └── readme-icon.png           # README 用图标
```

## 卸载

从「应用程序」中移除 `KeepAgentAwake.app` 即可。若曾在系统设置中为该应用授予过辅助功能、自动化等权限，可在 **系统设置 → 隐私与安全性** 中按需移除。

## Star History

<a href="https://star-history.com/#toddwyl/KeepAgentAwake&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=toddwyl/KeepAgentAwake&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=toddwyl/KeepAgentAwake&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=toddwyl/KeepAgentAwake&type=Date" width="600" />
  </picture>
</a>
