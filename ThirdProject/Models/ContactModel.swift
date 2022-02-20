//
//  ContactModel.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import Foundation
import UIKit
import Contacts

class ContactsModel {
 static var contactsSourceArray = Contacts(contacts: [Contact]())
  static let path = URL(fileURLWithPath: NSTemporaryDirectory())
  static let disk = DiskStorage(path: URL(fileURLWithPath: NSTemporaryDirectory()))
  static let storage = CodableStorage(storage: disk)

  var contactStore = CNContactStore()
  var contacts = [CNContact]()
  var authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

  func fetchCachedContacts() -> Contacts {
    do {
      let cached: Contacts = try ContactsModel.storage.fetch(for: "contactItem")
      for index in 0..<cached.contacts.count {
        ContactsModel.contactsSourceArray.contacts.append(cached.contacts[index])
      }
      return cached
    } catch {
      print(error)
    }
    return Contacts(contacts: [Contact]())
  }

   func formatPhoneNumber(number: String) -> String {
    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let mask = "+XXX XX XXX XX XX"
    var result = ""
    var index = cleanPhoneNumber.startIndex
    for character in mask where index < cleanPhoneNumber.endIndex {
      if character == "X" {
        result.append(cleanPhoneNumber[index])
        index = cleanPhoneNumber.index(after: index)
      } else {
        result.append(character)
      }
    }
    return result
  }

  func loadContacts() {
    do {
      contacts = [CNContact]()
      print(ContactsModel.path)
      let keysTofetch = [
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor]
      let request = CNContactFetchRequest(keysToFetch: keysTofetch)
      try contactStore.enumerateContacts(with: request, usingBlock: { cnContact, _ in
        self.contacts.append(cnContact)
      })
      for contact in 0..<self.contacts.count {
        var image = UIImage(named: "account")
        if contacts[contact].isKeyAvailable(CNContactImageDataKey) {
          if let ima = contacts[contact].imageData {
            image = UIImage(data: ima)
          }
        }

        let formatedPhoneNumber = formatPhoneNumber(number: (contacts[contact].phoneNumbers.first?.value.stringValue)!)

        let contactItem = Contact(name: contacts[contact].givenName + " " + contacts[contact].familyName,
                                  phoneNumber: formatedPhoneNumber,
                                  image: Image(withImage: image!))
        ContactsModel.contactsSourceArray.contacts.append(contactItem)
        saveToDisk()
      }
    } catch {
      print(error)
    }
  }

  func saveToDisk() {
    do {
      try ContactsModel.storage.save(ContactsModel.contactsSourceArray, for: "contactItem")
    } catch {
      print(error)
    }
  }
}

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
