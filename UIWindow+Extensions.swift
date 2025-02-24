// UIWindow+Extensions.swift --(无修改)
import UIKit
import SwiftUI

struct WindowKey: EnvironmentKey {
    static var defaultValue: UIWindow? { nil }
}

extension EnvironmentValues {
    var window: UIWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
}
