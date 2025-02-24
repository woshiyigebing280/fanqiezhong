// FlipClock.swift (无修改)
import SwiftUI

struct FlipClock: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    let fontSize: CGFloat

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.backgroundOpacity) var backgroundOpacity

    var body: some View {
        HStack(spacing: fontSize * 0.1) {
            // 将 .background 移到 FlipDigitView 内部
            FlipDigitView(digit: .constant(minutes / 10), fontSize: fontSize) {
                digitBackground // 传入背景
            }
            .foregroundColor(digitForegroundColor) // 数字颜色

            FlipDigitView(digit: .constant(minutes % 10), fontSize: fontSize) {
                digitBackground
            }
            .foregroundColor(digitForegroundColor)

            Text(":")
                .font(.system(size: fontSize, weight: .heavy, design: .monospaced))
                .foregroundColor(colonForegroundColor)

            FlipDigitView(digit: .constant(seconds / 10), fontSize: fontSize) {
                digitBackground
            }
            .foregroundColor(digitForegroundColor)

            FlipDigitView(digit: .constant(seconds % 10), fontSize: fontSize) {
                digitBackground
            }
            .foregroundColor(digitForegroundColor)
        }
    }

    // 实心背景框的 ViewBuilder (现在是一个普通的 View)
    private var digitBackground: some View {
        RoundedRectangle(cornerRadius: fontSize * 0.1)
            .fill(backgroundColor) // 根据 backgroundColor 填充
    }

    private var backgroundColor: Color{
        if backgroundOpacity == 1.0{
            return .white
        }else{
            return colorScheme == .dark ? .white : .black
        }
    }

    private var digitForegroundColor: Color {
       if backgroundOpacity == 1.0 {
            return .black
        } else {
            return colorScheme == .dark ? .black : .white
        }
    }

    private var colonForegroundColor: Color {
        if backgroundOpacity == 1.0 {
            return .white
        } else {
           return colorScheme == .dark ? .white : .black
        }
    }
}
