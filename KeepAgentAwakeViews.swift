import AppKit
import SwiftUI

/// Idle display-off presets in seconds. `0` disables automatic display-off.
private let idlePresets: [Int] = [0, 1, 5, 10, 30, 60, 120, 300, 600, 900, 1800, 3600]

private func idleChoices(current: Int) -> [Int] {
    var choices = Set(idlePresets)
    choices.insert(max(0, current))
    return choices.sorted()
}

/// Connects the SwiftUI window to AppDelegate for reliable show/hide behavior.
private struct MainWindowAccessor: NSViewRepresentable {
    @EnvironmentObject var app: AppDelegate

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            app.registerMainContentWindow(window)
        }
    }
}

struct MainWindowView: View {
    @EnvironmentObject var app: AppDelegate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                modeCard
                Divider()
                quickActions
                Divider()
                settingsSummary
                Spacer(minLength: 8)
            }
            .padding(24)
        }
        .frame(minWidth: 440, minHeight: 520)
        .background(MainWindowAccessor())
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            Group {
                if let icon = NSApp.applicationIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "display.and.arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 56, height: 56)
            .cornerRadius(12)
            VStack(alignment: .leading, spacing: 4) {
                Text("KeepAgentAwake")
                    .font(.title2.weight(.semibold))
                Text(tr("Menu bar · Never Sleep · Timed idle display-off"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var modeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tr("Current Status"))
                .font(.headline)
            HStack {
                statusBadge
                Spacer()
                if let start = app.modeStartTime {
                    Text(trf("Running %@", app.formattedDuration(since: start)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            Text(app.statusDetailText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(.quaternary.opacity(0.35))
        .cornerRadius(12)
    }

    private var statusBadge: some View {
        let (text, color) = app.statusBadge
        return Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(8)
    }

    private var quickActions: some View {
        let actionTitle = app.isProtectionOn ? tr("Restore Normal") : tr("Never Sleep")
        return VStack(alignment: .leading, spacing: 12) {
            Text(tr("Quick Actions"))
                .font(.headline)
            Button(actionTitle) {
                app.toggleProtectionFromUI()
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
            Text(tr("Enable Never Sleep; click again to Restore Normal and return to the default power policy. ⌘⇧P toggles · ⌘⌃⎋ emergency restore"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var settingsSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tr("Settings"))
                .font(.headline)
            Toggle(tr("Show timer in menu bar"), isOn: $app.showTimer)
            Divider().padding(.vertical, 4)
            Toggle(tr("Turn display off when idle (recommended)"), isOn: $app.smartIdleDisplayOff)
                .help(tr("When disabled, classic mode keeps the display on. When enabled, choose an idle display-off time, including Never."))
            HStack {
                Text(tr("Display-off idle time"))
                Spacer()
                Picker("", selection: $app.idleTimeoutSeconds) {
                    ForEach(idleChoices(current: app.idleTimeoutSeconds), id: \.self) { sec in
                        Text(Self.labelForIdleSeconds(sec)).tag(sec)
                    }
                }
                .frame(maxWidth: 240)
            }
            .disabled(!app.smartIdleDisplayOff)
            Toggle(tr("Dim keyboard backlight when display turns off"), isOn: $app.dimKeyboardOnIdleOff)
                .disabled(!app.smartIdleDisplayOff || app.idleTimeoutSeconds == 0)
            Toggle(tr("Prevent sleep with lid closed (pmset disablesleep)"), isOn: $app.keepAwakeOnLidClose)
                .help(tr("After Never Sleep is enabled, macOS will ask for an administrator password to run pmset -a disablesleep 1; Restore Normal attempts disablesleep 0."))
            Text(tr("When display-off is set to Never, displays do not turn off automatically. Keyboard backlight dimming uses simulated key presses. Lid-close protection requires administrator authorization."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button(tr("Focus menu bar icon")) {
                app.focusStatusItem()
            }
            Divider().padding(.vertical, 8)
            Button(tr("Quit KeepAgentAwake")) {
                app.quitApplication()
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }

    private static func labelForIdleSeconds(_ seconds: Int) -> String {
        if seconds == 0 { return tr("Never (do not turn display off when idle)") }
        if seconds < 60 { return trf("%d sec", seconds) }
        if seconds % 3600 == 0 { return trf("%d hr", seconds / 3600) }
        if seconds % 60 == 0 { return trf("%d min", seconds / 60) }
        return trf("%d sec", seconds)
    }
}
