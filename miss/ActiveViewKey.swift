//
//  ActiveViewKey.swift
//  miss
//
//  Created by hashimo ryoya on 2023/07/25.
//

import SwiftUI

struct ActiveViewKey: EnvironmentKey {
    static let defaultValue = Binding.constant("")
}

extension EnvironmentValues {
    var activeView: Binding<String> {
        get { self[ActiveViewKey.self] }
        set { self[ActiveViewKey.self] = newValue }
    }
}

