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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.importExport, addition: {
                Button(action: {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK {
                        self.notesDirBookmark = try? panel.url?.bookmarkData(
                            options: .withSecurityScope,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil)
                    }
                }, label: {
                    Text("Open folder...")
                })
            })
            SidebarCommands()
        }
    }
}
