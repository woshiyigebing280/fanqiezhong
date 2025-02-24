// CompletionCard.swift (单独的文件)
import SwiftUI

struct CompletionCard: View {
    var onRest: () -> Void
    @Environment(\.colorScheme) var colorScheme

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        VStack {
            Text("时间到了，休息一下吧！")  //这里我将文字修改了，和“休息一下”按钮区分
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(textColor)
                .padding()

            Button(action: {
                onRest() // 调用传入的休息操作
            }) {
                Text("OK") //这里我将文字修改为“休息一下”，你可以按自己喜好修改
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10) // 正确的写法
                    .background(textColor)
                    .cornerRadius(25)
            }
        }
        .padding()
        .background(colorScheme == .dark ? .black.opacity(0.8) : .white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
