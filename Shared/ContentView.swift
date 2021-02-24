//
//  ContentView.swift
//  Shared
//
//  Created by Quentin Eude on 09/02/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $appState.searchText)
                //It's a bit weird that I need to do that here, but if I don't I get an error when the displayedFiles list is empty
                if !appState.displayedFiles.isEmpty {
                    List(appState.displayedFiles) { file in
                        NavigationLink(
                            file.name,
                            destination: EditorView(text: $appState.selectedFileText),
                            tag: file.id,
                            selection: $appState.selectedFileId
                        )
                    }
                    .listStyle(SidebarListStyle())
                } else {
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .status) {
                    Button(action: {
                        toggleSidebar()
                    }) {
                        Image(systemName: "sidebar.left")
                    }
                }
                ToolbarItem(placement: .status) {
                    Spacer()
                }
                ToolbarItem(placement: .status) {
                    Button(action: {
                        appState.addFile()
                    }) {
                        Image(systemName: "plus.app")
                    }
                }
            }
        }
    }
}

func toggleSidebar() {
    #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
