//
//  Image.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 27.06.22.
//

import Foundation
import UIKit

struct Image: Codable {
  let imageData: Data?
  init(withImage image: UIImage) {
	self.imageData = image.pngData()
  }
  func getImage() -> UIImage? {
	guard let imageData = self.imageData else {
	  return nil
	}
	let image = UIImage(data: imageData)
	return image
  }
}
