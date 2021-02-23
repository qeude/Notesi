//
//  Binding+Extensions.swift
//  Notesi
//
//  Created by Quentin Eude on 23/02/2021.
//

import Foundation
import SwiftUI
import CocoaLumberjackSwift

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
