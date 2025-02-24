//  SceneDelegate.swift (无修改)
import UIKit
import SwiftUI
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView().environment(\.window, window)) // 把“窗户”写进“记事本”
            self.window = window
            window.makeKeyAndVisible()
        }

    }
}
