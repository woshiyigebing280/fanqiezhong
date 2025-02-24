// DigitView.swift (无修改)
import SwiftUI

struct DigitView: View {
    let digit: Int
    let fontSize: CGFloat
    // 不需要 @Environment(\.colorScheme) var colorScheme  // 移除

    var body: some View {
        Text("\(digit)")
            .font(.system(size: fontSize, weight: .heavy, design: .monospaced))
            .frame(width: fontSize * 0.65, height: fontSize)
            // 不要加任何背景或前景色的修饰符
            .cornerRadius(fontSize * 0.1) //只保留圆角
    }
}
