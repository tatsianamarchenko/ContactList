//
//  InfoAboutContactViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class InfoAboutContactViewController: UIViewController, UITextFieldDelegate {

  var numberInArray = 0
  var isEdit = false

  private lazy var image: UIImageView = {
    var image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.backgroundColor = .systemGray3
    image.contentMode = .scaleAspectFill
    return image
  }()

  private lazy var favoriteButton: IndexedButton = {
    var favoriteButton = IndexedButton(buttonIndexPath: IndexPath(index: 0))
    favoriteButton.translatesAutoresizingMaskIntoConstraints = false
    favoriteButton.contentMode = .scaleAspectFill
    favoriteButton.addTarget(self, action: #selector(addToFavorte), for: .touchUpInside)
    return favoriteButton
  }()

  @objc func addToFavorte(_ sender: IndexedButton) {
    let index = sender.buttonIndexPath.row
    contactsSourceArray.contacts[index].isFavorite.toggle()
    if   contactsSourceArray.contacts[index].isFavorite == true {
      favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(
        .systemRed,
        renderingMode: .alwaysOriginal),
                              for: .normal)
      saveToArray()
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart")?.withTintColor(.systemRed,
                                                                          renderingMode: .alwaysOriginal), for: .normal)
      saveToArray()
    }
  }

  private lazy var fullName: UITextField = {
    var textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont.systemFont(ofSize: 20)
    textField.textColor = .label
    textField.isUserInteractionEnabled = false
    textField.keyboardType = .default
    return textField
  }()

  private lazy var phoneNumber: UITextField = {
    var textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont.systemFont(ofSize: 20)
    textField.textAlignment = .center
    textField.textColor = .secondaryLabel
    textField.isUserInteractionEnabled = false
    textField.keyboardType = .namePhonePad
    return textField
  }()

  func createStack(textField: UITextField, name: String) -> UIStackView {
    let lable = UILabel()
    lable.text = name
    lable.font = UIFont.systemFont(ofSize: 20)
    textField.textColor = .label

    let stack = UIStackView(arrangedSubviews: [lable, textField])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.backgroundColor = .systemGray6
    stack.clipsToBounds = true
    stack.layer.cornerRadius = 10
    view.addSubview(stack)
    return stack
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    phoneNumber.delegate = self
    fullName.delegate = self
    let emailButton = UIBarButtonItem(image: isEdit ? UIImage(systemName: "square.and.arrow.down.fill")! :
                                        UIImage(systemName: "e.square.fill")!,
                                      style: .plain,
                                      target: self,
                                      action: #selector(editInfo))

    navigationItem.rightBarButtonItem = emailButton

    let stackFullName = createStack(textField: fullName, name: "имя")
    let stackPhoneNumber = createStack(textField: phoneNumber, name: "номер")

    let mainStack = UIStackView(arrangedSubviews: [image, stackFullName, stackPhoneNumber, favoriteButton])
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    mainStack.axis = .vertical
    mainStack.alignment = .center
    view.addSubview(mainStack)

    NSLayoutConstraint.activate([
      mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      //    stackFullName.heightAnchor.constraint(equalToConstant: 50),
      stackFullName.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),

      stackPhoneNumber.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 10),
      stackPhoneNumber.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),

      image.widthAnchor.constraint(equalToConstant: 150),
      image.heightAnchor.constraint(equalToConstant: 150)
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    image.clipsToBounds = true
    image.layer.cornerRadius = 75
  }

  init(imageItem: UIImage, titleItem: String, item: Contact, indexPath: IndexPath) {
    super.init(nibName: nil, bundle: nil)
    image.image = imageItem
    fullName.text = item.name
    phoneNumber.text = item.phoneNumber
    self.title = titleItem
    self.numberInArray = indexPath.row
    favoriteButton.setImage(UIImage(systemName:
                                      item.isFavorite ?
                                    "heart.fill" : "heart")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                            for: .normal)
    favoriteButton.buttonIndexPath = indexPath
  }

  @objc func editInfo() {
    isEdit.toggle()
    print(isEdit)
    if isEdit == true {
      fullName.isUserInteractionEnabled = true
      phoneNumber.isUserInteractionEnabled = true
      fullName.becomeFirstResponder()
    } else {
      fullName.isUserInteractionEnabled = false
      fullName.resignFirstResponder()
      contactsSourceArray.contacts[numberInArray].name = fullName.text!
      saveToArray()
      phoneNumber.isUserInteractionEnabled = false
      phoneNumber.resignFirstResponder()
      contactsSourceArray.contacts[numberInArray].phoneNumber = phoneNumber.text!
      saveToArray()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func saveToArray () {
    do {
      try Helper.storage.save(contactsSourceArray, for: "contactItem")
    } catch {
      print(error)
    }
  }

  let reg = try? NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)

  func format (phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {

    guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else {
      return "+"
    }
    let range = NSString(string: phoneNumber).range(of: phoneNumber)
    var number = reg!.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")
    if number.count > 11 {
      let max = number.index(number.startIndex, offsetBy: 11)
      number = String(number[number.startIndex..<max])
    }

    if shouldRemoveLastDigit {
      let max = number.index(number.startIndex, offsetBy: number.count - 1)
      number = String(number[number.startIndex..<max])
    }

    let maxIndex = number.index(number.startIndex, offsetBy: number.count)
    let regRange = number.startIndex..<maxIndex

    if number.count < 7 {
      let pattern = "(\\d{3})(\\d{2})(\\d{2})"
      number = number.replacingOccurrences(of: pattern, with: "$1 $2 $3", options: .regularExpression, range: regRange)
    } else {
      let pattern = "(\\d{3})(\\d{2})(\\d{3})(\\d{2})(\\d{2})"
      number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3 $4 $5",
                                           options: .regularExpression, range: regRange)
    }
    return "+" + number
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    let full = (textField.text ?? "") + string
    textField.text = format(phoneNumber: full, shouldRemoveLastDigit: range.length == 1)
    return false
  }

}
