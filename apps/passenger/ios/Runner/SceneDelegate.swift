import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // Avoid a pure white flash / blank frame before Flutter paints.
    if let windowScene = scene as? UIWindowScene {
      windowScene.windows.forEach { window in
        window.backgroundColor = UIColor(red: 0.05, green: 0.09, blue: 0.16, alpha: 1)
      }
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    if let windowScene = scene as? UIWindowScene {
      windowScene.windows.forEach { window in
        window.backgroundColor = UIColor(red: 0.05, green: 0.09, blue: 0.16, alpha: 1)
        window.rootViewController?.view.backgroundColor =
          UIColor(red: 0.05, green: 0.09, blue: 0.16, alpha: 1)
      }
    }
  }
}
