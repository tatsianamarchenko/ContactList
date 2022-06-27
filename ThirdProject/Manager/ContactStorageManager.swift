//
//  ContactStorageManager.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 27.06.22.
//

import Foundation
import UIKit
import Contacts

class ContactStorageManager {
	static var contactsSourceArray = Contacts(contacts: [Contact]())
	static let path = URL(fileURLWithPath: NSTemporaryDirectory())
	static let storage = CodableStorage(storage: ContactStorageManager().disk)

	let disk = DiskStorage(path: URL(fileURLWithPath: NSTemporaryDirectory()))
	let contactStore = CNContactStore()
	var contacts = [CNContact]()
	var authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

	func fetchCachedContacts() -> Contacts {
		do {
			let cached: Contacts = try ContactStorageManager.storage.fetch(for: "contactItem")
			for index in 0..<cached.contacts.count {
				ContactStorageManager.contactsSourceArray.contacts.append(cached.contacts[index])
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
				ContactStorageManager.contactsSourceArray.contacts.append(contactItem)
				saveToDisk()
			}
		} catch {
			print(error)
		}
	}

	func saveToDisk() {
		do {
			try ContactStorageManager.storage.save(ContactStorageManager.contactsSourceArray, for: "contactItem")
		} catch {
			print(error)
		}
	}
}
