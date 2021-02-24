//
//  Binding+Extensions.swift
//  Notesi
//
//  Created by Quentin Eude on 23/02/2021.
//

import CocoaLumberjackSwift
import Foundation
import SwiftUI

func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
