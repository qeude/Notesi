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
    var id: String { name }
}

struct ContentView: View {
    @AppStorage("notesDirBookmark") var notesDirBookmark: Data?

    @State var text: String = ""
    @State var dirPath: URL?
    @State var filesList: [File] = []
    
    var body: some View {
        NavigationView {
            Group {
                List {
                    ForEach(filesList) { file in
                        NavigationLink(
                            destination:
                                EditorView(text: file.name)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        ) {
                            Text(file.name)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .onAppear {
                self.restoreFileAccess()
                self.listFiles()
            }
        }
    }
    
    func listFiles() {
        let fm = FileManager.default
        
        guard let dirPath = self.dirPath else {
            return
        }

        if !dirPath.startAccessingSecurityScopedResource() {
            print("startAccessingSecurityScopedResource returned false. This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?")
        }
        
        do {
            let items = try fm.contentsOfDirectory(atPath: dirPath.path)
            self.filesList = items.compactMap { File(name: $0, path: $0) }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        dirPath.stopAccessingSecurityScopedResource()

    }
    
    private func restoreFileAccess() {
        guard let notesDirBookmark = notesDirBookmark else {
            return
        }
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: notesDirBookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                self.notesDirBookmark = try? url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil)
            }
            self.dirPath = url
        } catch {
            print("Error resolving bookmark:", error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
