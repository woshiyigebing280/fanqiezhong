// CycleCompletionCard.swift
import SwiftUI

struct CycleCompletionCard: View {
    var currentCycle: Int // 使用普通属性
    var onConfirm: () -> Void
    @Environment(\.colorScheme) var colorScheme

     var body: some View {
         VStack {
             // 直接使用传入的 currentCycle
             Text("恭喜你完成了 \(currentCycle) 个番茄钟循环！")
                 .font(.system(size: 20, weight: .bold))
                 .foregroundColor(textColor)
                 .padding()

             Button(action: {
                 onConfirm()
             }) {
                 Text("确认继续")
                     .font(.system(size: 16, weight: .medium))
                     .foregroundColor(.white)
                     .padding(.horizontal, 20)
                     .padding(.vertical, 10)
                     .background(textColor)
                     .cornerRadius(25)
             }
         }
         .padding()
         .background(colorScheme == .dark ? .black.opacity(0.8) : .white.opacity(0.9))
         .cornerRadius(20)
         .shadow(radius: 10)

     }
     private var textColor: Color {
         colorScheme == .dark ? .white : .black
     }
}
