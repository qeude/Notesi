//
//  File.swift
//  Notesi
//
//  Created by Quentin Eude on 16/02/2021.
//

import Foundation

struct File: Identifiable {
    let name: String
    let url: URL
    let lastDateModified: Date

    var id: String { url.path }
}
