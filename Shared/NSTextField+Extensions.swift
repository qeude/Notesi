//
//  NSTextField+Extensions.swift
//  Notesi
//
//  Created by Quentin Eude on 16/02/2021.
//
import SwiftUI

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set {}
    }
}
