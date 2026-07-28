import SwiftUI

@main
struct KeepAgentAwakeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(appDelegate)
        }
        .defaultSize(width: 480, height: 620)
        .commands {
            CommandGroup(replacing: .appInfo) {}
            CommandGroup(after: .appInfo) {
                Button(tr("About KeepAgentAwake…")) {
                    appDelegate.showAboutWindow()
                }
            }
        }
    }
}
