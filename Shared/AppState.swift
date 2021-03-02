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
    @Published var displayedFiles: [File] = []
    @Published var selectedFileId: String? {
        didSet {
            let file = self.files.first(where: { $0.id == selectedFileId })
            self.select(file: file)
        }
    }
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
        let lastSelectedFileId = UserDefaults.standard.string(forKey: "lastSelectedFileId")
        let lastSelectedFile = self.files.first(where: { $0.id == lastSelectedFileId })
        self.select(file: lastSelectedFile)
    }

    func select(file: File?) {
        if let file = file {
            getTextFromFile(fileURL: file.url)
            UserDefaults.standard.set(file.id, forKey: "lastSelectedFile")
        } else {
            UserDefaults.standard.removeObject(forKey: "lastSelectedFile")
        }
    }

    func addFile() {

    }

    private func filterFiles(with text: String? = nil) {
        self.displayedFiles = self.files
            .filter {
                if let filteringText = text, !filteringText.isEmpty {
                    return $0.url.lastPathComponent.lowercased().contains(filteringText)
                }
                return true
            }
            .sorted(by: { (f1, f2) -> Bool in
                f1.lastDateModified > f2.lastDateModified
            })
    }

    func listFiles() {
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
            self.filterFiles(with: searchText)
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
            if !url.startAccessingSecurityScopedResource() {
                DDLogError("Couldn't access: \(url.path)")
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

    func saveCurrentFile() {
        if let selectedFileId = selectedFileId {
            self.save(fileId: selectedFileId)
        }
    }

    private func save(fileId: String) {
        guard let file = self.files.first(where: { $0.id == fileId }) else {
            return
        }
        do {
            try self.selectedFileText?.write(to: file.url, atomically: true, encoding: .utf8)
        } catch {
            DDLogError(
                "Error writing to file \(file.id): \(error.localizedDescription)")
        }
    }

    private func setupSubscribers() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { filteringText in
                self.filterFiles(with: filteringText)
            }
            .store(in: &disposables)

        NotificationCenter.default.publisher(for: Notification.Name("didSelectedDirChange"))
            .sink { _ in
                self.compute()
            }
            .store(in: &disposables)
    }
}
