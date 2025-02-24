//FlipDigitView.swift (无修改)
import SwiftUI
struct FlipDigitView<Background: View>: View {
    @Binding var digit: Int
    let fontSize: CGFloat
    @State private var nextDigit: Int? = nil // 用于平滑过渡
    @State private var scale: CGFloat = 1.0 // 缩放比例

    let background: Background

    init(digit: Binding<Int>, fontSize: CGFloat, @ViewBuilder background: () -> Background) {
        self._digit = digit
        self.fontSize = fontSize
        self.background = background()
    }

    var body: some View {
        ZStack {
            // 当前数字
            ZStack {
                background
                DigitView(digit: digit, fontSize: fontSize)
            }
            .frame(width: fontSize * 0.65, height: fontSize)
            .clipped()
            .scaleEffect(scale) // 应用缩放

            // 下一个数字 (用于过渡)
            if let nextDigit = nextDigit {
                ZStack {
                    background
                    DigitView(digit: nextDigit, fontSize: fontSize)
                }
                .frame(width: fontSize * 0.65, height: fontSize)
                .clipped()
                .scaleEffect(scale) // 也应用缩放
            }
        }
        .onChange(of: digit) { oldValue, newValue in
            if oldValue != newValue {
                nextDigit = newValue // 设置下一个数字

                // 动画：缩小
                withAnimation(.easeInOut(duration: 0.2)) {
                    scale = 0.8
                }

                // 动画：恢复大小
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                         self.digit = newValue  //赋值
                        scale = 1.0
                         nextDigit = nil
                    }
                }
            }
        }
    }
}
