//
//  ContactModel.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import Foundation
import UIKit

struct Contacts: Codable {
  var contacts: [Contact]
}

struct Contact: Codable {
  var name: String
  var phoneNumber: String
  var image: Image
  var isFavorite = false
}

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
