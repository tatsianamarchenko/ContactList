//
//  ContactModel.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import Foundation
import UIKit

struct Contact: Codable {
  var name: String
  var phoneNumber: String
  var image: Image
  var isFavorite = false
}

struct Contacts: Codable {
  var contacts: [Contact]
}
