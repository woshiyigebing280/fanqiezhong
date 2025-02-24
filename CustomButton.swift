// CustomButton.swift (无修改)
import SwiftUI

struct CustomButton: View {
    let label: String
    let gradient: LinearGradient // 修改：使用 LinearGradient
    
    var body: some View {
        Text(label)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .black : .white) // 根据系统模式反转颜色
            .padding()
            .frame(maxWidth: .infinity)
            .background(gradient)
            .cornerRadius(30)
    }
    //新增
    @Environment(\.colorScheme) var colorScheme
}
