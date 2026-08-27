import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    let brand = UIColor(red: 0.05, green: 0.09, blue: 0.16, alpha: 1)
    if let windowScene = scene as? UIWindowScene {
      for window in windowScene.windows {
        window.backgroundColor = brand
        window.rootViewController?.view.backgroundColor = brand
      }
    }
  }
}
