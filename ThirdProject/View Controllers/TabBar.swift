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

  private func setupVCs() {
    let personImage = UIImage(systemName: "person.crop.circle")
    guard let personImage = personImage else {
      return
    }
    let personFillImage = UIImage(systemName: "person.crop.circle.fill")
    guard let personFillImage = personFillImage else {
      return
    }
    let starImage = UIImage(systemName: "star")
    guard let starImage = starImage else {
      return
    }
    let starFillImage = UIImage(systemName: "star.fill")
    guard let starFillImage = starFillImage else {
      return
    }

    viewControllers = [
      createNavController(for: CantactsViewController(),
                             title: NSLocalizedString("contacts", comment: ""),
                             image: personImage,
                             selectedImage: personFillImage),
      createNavController(for: FavoriteViewController(),
                             title: NSLocalizedString("favorite", comment: ""),
                             image: starImage,
                             selectedImage: starFillImage)
    ]
  }

  private func createNavController(for rootViewController: UIViewController,
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
