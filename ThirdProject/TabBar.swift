//
//  TabBar.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .systemBackground
      UITabBar.appearance().barTintColor = .systemBackground
      tabBar.tintColor = .label
      setupVCs()
    }

  func setupVCs() {
    viewControllers = [
      createNavController(for: CantactsViewController(), title: NSLocalizedString("contacts", comment: ""),
                             image: UIImage(systemName: "person.crop.circle.fill")!),
      createNavController(for: FavoriteViewController(), title: NSLocalizedString("favorite", comment: ""),
                             image: UIImage(systemName: "star.fill")!)
    ]
  }

  fileprivate func createNavController(for rootViewController: UIViewController,
                                       title: String,
                                       image: UIImage) -> UIViewController {
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem.title = title
    navController.tabBarItem.image = image
    navController.navigationBar.prefersLargeTitles = true
    rootViewController.navigationItem.title = title
    return navController
  }
}
