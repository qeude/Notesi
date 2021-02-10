//
//  NotesiApp.swift
//  Shared
//
//  Created by Quentin Eude on 09/02/2021.
//

import SwiftUI

@main
struct NotesiApp: App {
    @AppStorage("notesDirBookmark") var notesDirBookmark: Data?
    
    var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.importExport, addition: {
                Button(action: {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK {
                        let bookmarkData = try? panel.url?.bookmarkData(
                            options: .withSecurityScope,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil)
                        UserDefaults.standard.setValue(bookmarkData, forKey: "dirBookmark")
                        NotificationCenter.default
                            .post(name: Notification.Name("didSelectedDirChange"),
                                  object: bookmarkData)
                    }
                }, label: {
                    Text("Open folder...")
                })
            })
            SidebarCommands()
        }
    }
}
