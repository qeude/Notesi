//
//  ContentView.swift
//  Shared
//
//  Created by Quentin Eude on 09/02/2021.
//

import SwiftUI

struct File: Identifiable {
    let name: String
    let path: String
    let fullPath: String
    var id: String { name }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            Group {
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
            .onAppear {
                appState.compute()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didSelectedDirChange"))) { _ in
                appState.compute()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
