// ActionButton.swift (无修改)
import SwiftUI

struct ActionButton: View {
    let label: String
    let gradient : LinearGradient
    let action: () -> Void
    //新增
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .black : .white) // 根据系统模式反转颜色
                .padding()
                .frame(width: 130)
                .background(gradient)
                .cornerRadius(30)
            
        }
    }
}
