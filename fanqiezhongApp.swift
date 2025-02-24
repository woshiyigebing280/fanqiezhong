//  fanqiezhongApp.swift （无修改）
import SwiftUI

@main  // 添加 @main 标记
struct fanqiezhongApp: App {  //(修改)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //新增
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
