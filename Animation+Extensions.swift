// Animation+Extensions.swift (无修改)
import SwiftUI

extension Animation {
    static var flip: Animation {
        .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.6) // 你可以调整这里的曲线和时长
    }
}
