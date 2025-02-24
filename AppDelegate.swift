//AppDelegate.swift (无修改)
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
   // static var orientationLock = UIInterfaceOrientationMask.landscapeRight { //修改初始值
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                         windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                UIApplication.shared.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                 //iOS 16 之前的版本，这部分可以移除，因为不再强制横屏。如果需要支持老版本，保留
                if orientationLock == .landscapeRight {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                   UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock //保持不变
    }
}

extension UIApplication {  //新增
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first
    }
}
