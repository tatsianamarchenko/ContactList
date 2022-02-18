//
//  TabBar.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class TabBar: UITabBarController {

  private lazy var animation: CAKeyframeAnimation = {
    let animation = CAKeyframeAnimation(keyPath: "transform.scale")
    animation.values = [1.0, 1.1, 0.9, 1.02, 1.0]
    animation.duration = TimeInterval(0.3)
    animation.calculationMode = CAAnimationCalculationMode.cubic
    return animation
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    UITabBar.appearance().barTintColor = .systemBackground
    tabBar.tintColor = .label
    setupVCs()
  }

  func setupVCs() {
    viewControllers = [
      createNavController(for: CantactsViewController(),
                             title: NSLocalizedString("contacts", comment: ""),
                             image: UIImage(systemName: "person.crop.circle")!,
                             selectedImage: UIImage(systemName: "person.crop.circle.fill")!),
      createNavController(for: FavoriteViewController(),
                             title: NSLocalizedString("favorite", comment: ""),
                             image: UIImage(systemName: "star")!,
                             selectedImage: UIImage(systemName: "star.fill")!)
    ]
  }

  fileprivate func createNavController(for rootViewController: UIViewController,
                                       title: String,
                                       image: UIImage, selectedImage: UIImage) -> UIViewController {
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem.title = title
    navController.tabBarItem.selectedImage = selectedImage
    navController.tabBarItem.image = image
    navController.navigationBar.prefersLargeTitles = true
    rootViewController.navigationItem.title = title
    return navController
  }
}

extension TabBar: UITabBarControllerDelegate {
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    guard let imageView = item.value(forKey: "view") as? UIView else { return }
    imageView.layer.add(animation, forKey: nil)
  }
}