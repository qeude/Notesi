//
//  AppState.swift
//  Notesi
//
//  Created by Quentin Eude on 10/02/2021.
//

import Foundation

class AppState: ObservableObject {
    @Published var files: [File] = []
    @Published var selectedFileText: String?
    @Published var dirPath: URL?

    init() {
        self.compute()
    }
    
    func compute() {
        let dirBookmark = UserDefaults.standard.data(forKey: "dirBookmark")
        self.restoreFileAccess(for: dirBookmark)
        self.listFiles()
    }
    
    func select(file: File) {
        getTextFromFile(filePath: file.fullPath)
    }
    
    private func listFiles() {
        let fm = FileManager.default
        
        guard let dirPath = self.dirPath else {
            return
        }

        if !dirPath.startAccessingSecurityScopedResource() {
            print("startAccessingSecurityScopedResource returned false. This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?")
        }
        
        do {
            let items = try fm.contentsOfDirectory(atPath: dirPath.path)
            self.files = items.compactMap { File(name: $0, path: $0, fullPath: "\(dirPath.path)/\($0)") }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        dirPath.stopAccessingSecurityScopedResource()
    }
    
    private func restoreFileAccess(for dirBookmark: Data?) {
        guard let dirBookmark = dirBookmark else {
            return
        }
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: dirBookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                let bookmarkData = try? url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil)
                UserDefaults.standard.set(bookmarkData, forKey: "dirBookmark")
            }
            dirPath = url
        } catch {
            print("Error resolving bookmark:", error)
        }
    }
    
    
    private func getTextFromFile(filePath: String) {
        if let fileURL = URL(string: filePath) {
            do {
                self.selectedFileText = try String(contentsOfFile: fileURL.path, encoding: .utf8)
                return
            } catch {
                print("Error getting text from file \(filePath)")
            }
        }
        self.selectedFileText = nil
    }
}
