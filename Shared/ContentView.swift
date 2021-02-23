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
                List {
                    ForEach(appState.files) { file in
                        NavigationLink(
                            destination:
                                EditorView(text: $appState.selectedFileText)
                                .onAppear {
                                    appState.select(file: file)
                                }
                        ) {
                            Text(file.name)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
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
            .onAppear {
                appState.compute()
            }
        }
    }
}

func toggleSidebar() {
    #if os(macOS)
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
