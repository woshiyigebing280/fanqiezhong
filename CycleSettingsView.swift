// CycleSettingsView.swift
import SwiftUI

struct CycleSettingsView: View {
    @Binding var isCycleEnabled: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header:
                    VStack(alignment: .leading, spacing: 4) { // 添加 spacing
                        Text("番茄钟循环")
                            .foregroundColor(textColor)
                            .font(.title2)        // 改为 .title2 或 .headline
                            .fontWeight(.bold)

                        Text("开启番茄钟循环，让专注与休息交替进行，保持高效工作状态。")
                            .foregroundColor(textColor)
                            .font(.subheadline) // 改为 .subheadline 或 .body
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 8) // 添加垂直内边距
                )
                {
                    Toggle(isOn: $isCycleEnabled) {
                        Text("启用循环")
                            .foregroundColor(textColor)
                    }
                }
            }
            .navigationBarTitle("循环设置", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(textColor)
                }
                ToolbarItem(placement: .principal) {
                    Text("循环设置").font(.headline).foregroundColor(textColor)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}
