// TimeSettingSection.swift (无修改)

import SwiftUI

struct TimeSettingSection: View {
    let title: String
    @Binding var value: Int
    let currentSession: Bool
    @Environment(\.colorScheme) var colorScheme //新增
    
    private let customFont = Font.system(size: 17, weight: .medium, design: .default)
    
    //修改：根据系统模式设置颜色
    private var baseColor: Color {
        colorScheme == .dark ? .black : .white
    }
    //新增
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var body: some View {
        Section(header: Text(title).font(customFont).foregroundColor(textColor.opacity(0.8))) {
            HStack {
                Text("\(value) 分钟")
                    .font(customFont)
                    .foregroundColor(currentSession ? textColor : textColor.opacity(0.7))
                Stepper("", value: $value, in: 1...60)
                    .labelsHidden()
            }
            if currentSession {
                Text("当前周期生效中")
                    .font(.caption)
                    .foregroundColor(textColor.opacity(0.7))  //修改
            }
        }
    }
}
