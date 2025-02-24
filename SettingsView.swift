// SettingsView.swift
import SwiftUI
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var timerModel: TimerModel
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("focusTime") var focusTime = 25
    @AppStorage("breakTime") var breakTime = 5

    // 循环设置,只保留isCycleEnabled
    @Binding var isCycleEnabled: Bool
    //@Binding var cycleCount: Int //删除

     private var baseColor: Color {
        colorScheme == .dark ? .black : .white
    }
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
         ZStack {
             baseColor
                 .edgesIgnoringSafeArea(.all)

             Form {
                 TimeSettingSection(
                     title: "专注时间",
                     value: $focusTime,
                     currentSession: timerModel.isFocusSession
                 )

                 TimeSettingSection(
                     title: "休息时间",
                     value: $breakTime,
                     currentSession: !timerModel.isFocusSession
                 )
             }
             .scrollContentBackground(.hidden)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("完成") {
                         dismiss()
                     }
                     .foregroundColor(textColor)
                 }
                 ToolbarItem(placement: .principal) {
                     Text("时间设置").font(.headline).foregroundColor(textColor)
                 }
             }
             .navigationBarTitleDisplayMode(.inline)
              .toolbarBackground(.visible, for: .navigationBar)
             .toolbarBackground(baseColor, for: .navigationBar)
         }
          .accentColor(textColor)
     }

    private func dismiss() {
        if timerModel.isRunning {
            timerModel.resetAndStart()
        }else{
            timerModel.syncTimeSetting()
            timerModel.updateTargetTime()
        }
        presentationMode.wrappedValue.dismiss()
    }
}
