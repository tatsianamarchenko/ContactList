//
//  SceneDelegate.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else {
      return
    }
    window = UIWindow(frame: UIScreen.main.bounds)
    let home = TabBar()
    self.window?.rootViewController = home
    window?.makeKeyAndVisible()
    window?.windowScene = windowScene
  }
}
