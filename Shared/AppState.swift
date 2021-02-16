//
//  AppState.swift
//  Notesi
//
//  Created by Quentin Eude on 10/02/2021.
//

import CocoaLumberjackSwift
import Combine
import Foundation

class AppState: ObservableObject {
    private var disposables = Set<AnyCancellable>()

    @Published var files: [File] = []
    @Published var selectedFileText: String?
    @Published var dirPath: URL?
    @Published var searchText = ""

    init() {
        self.compute()
        self.setupSubscribers()
    }

    func compute() {
        let dirBookmark = UserDefaults.standard.data(forKey: "dirBookmark")
        self.restoreFileAccess(for: dirBookmark)
        self.listFiles()
    }

    func select(file: File) {
        getTextFromFile(fileURL: file.url)
    }

    func listFiles(filteringText: String? = nil) {
        let fm = FileManager.default

        guard let dirPath = self.dirPath else {
            return
        }

        if !dirPath.startAccessingSecurityScopedResource() {
            DDLogInfo(
                "startAccessingSecurityScopedResource returned false. This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?"
            )
        }

        do {
            let items = try fm.contentsOfDirectory(
                at: dirPath,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles)
            self.files =
                items
                .filter { $0.pathExtension == "md" }
                .filter {
                    if let filteringText = filteringText {
                        return $0.deletingPathExtension().lastPathComponent.contains(filteringText)
                    }
                    return true
                }
                .compactMap { url -> File? in
                    let modificationDate =
                        try?
                        url.resourceValues(forKeys: [.contentModificationDateKey])
                        .contentModificationDate
                        ?? Date.distantPast
                    return File(
                        name: url.deletingPathExtension().lastPathComponent, url: url,
                        lastDateModified: modificationDate ?? Date.distantPast)
                }
                .sorted(by: { (f1, f2) -> Bool in
                    f1.lastDateModified > f2.lastDateModified
                })
        } catch {
            DDLogError("Error while loading items: \(error)")
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
                NotificationCenter.default
                    .post(
                        name: Notification.Name("didSelectedDirChange"),
                        object: bookmarkData)
            }
            dirPath = url
            DDLogDebug("Changed dirPath to \(String(describing: dirPath?.path))")
        } catch {
            DDLogError("Error resolving bookmark: \(error.localizedDescription)")
        }
    }

    private func getTextFromFile(fileURL: URL?) {
        if let fileURL = fileURL {
            do {
                self.selectedFileText = try String(contentsOfFile: fileURL.path, encoding: .utf8)
                return
            } catch {
                DDLogError(
                    "Error getting text from file \(fileURL.path): \(error.localizedDescription)")
            }
        }
        self.selectedFileText = nil
    }

    private func setupSubscribers() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { filteringText in
                if filteringText.isEmpty {
                    self.listFiles()
                } else {
                    self.listFiles(filteringText: filteringText)
                }
            }
            .store(in: &disposables)
    }
}
