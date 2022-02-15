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
    guard let windowScene = (scene as? UIWindowScene) else { return }
           window = UIWindow(frame: UIScreen.main.bounds)
           let home = TabBar()
           self.window?.rootViewController = home
           window?.makeKeyAndVisible()
           window?.windowScene = windowScene
  }
  //    do {
  //      let predicate = CNContact.predicateForContacts(matchingName: "Даша")
  //      var contacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: [
  //        CNContactFamilyNameKey as CNKeyDescriptor,
  //        CNContactGivenNameKey as CNKeyDescriptor,
  //        CNContactPhoneNumbersKey as CNKeyDescriptor
  //      ])
  //      contacts = contacts.filter{$0.familyName == ""}
  //      guard let contact = contacts.first else {
  //        print("no such contact")
  //        return
  //      }
  //      if contact.phoneNumbers.count > 0 {
  //        let number = contact.phoneNumbers[0]
  //        print(number)
  //      }
  //    } catch  {
  //      print("error")
  //    }
}
