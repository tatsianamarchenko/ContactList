//
//  InfoAboutContactViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class InfoAboutContactViewController: UIViewController {

var contactsModel = ContactsModel()
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

  private lazy var fullName: UITextField = {
    var textField = UITextField()
    configTextField(textField: textField)
    textField.keyboardType = .default
    textField.autocapitalizationType = .words
    textField.autocorrectionType = .no
    textField.placeholder = "Введите имя"
    return textField
  }()

  private lazy var phoneNumber: UITextField = {
    var textField = UITextField()
    configTextField(textField: textField)
    textField.keyboardType = .phonePad
    textField.placeholder = "Введите номер"
    return textField
  }()

  func configTextField (textField: UITextField) {
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont.systemFont(ofSize: 20)
    textField.textAlignment = .center
    textField.textColor = .label
    textField.clearButtonMode = .whileEditing
    textField.isUserInteractionEnabled = false
    textField.contentMode = .center
  }

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
    createBarButton()
    let stackFullName = createStack(textField: fullName, name: "Имя")
    let stackPhoneNumber = createStack(textField: phoneNumber, name: "Номер")

    let mainStack = UIStackView(arrangedSubviews: [image, stackFullName, stackPhoneNumber, favoriteButton])
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    mainStack.axis = .vertical
    mainStack.alignment = .center
    view.addSubview(mainStack)

    NSLayoutConstraint.activate([
      mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackFullName.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
      stackPhoneNumber.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
      image.widthAnchor.constraint(equalToConstant: 120),
      image.heightAnchor.constraint(equalToConstant: 120)
    ])

    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                           object: nil,
                                           queue: nil) { [self] notification in
      if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]
           as? NSValue)?.cgRectValue) != nil {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
          self.view.frame.origin.y = -70
          self.view.layoutIfNeeded()
        })
      }
    }
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                           object: nil,
                                           queue: nil) { notification in
      if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]
            as? NSValue)?.cgRectValue) != nil {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
          self.view.frame.origin.y = 0
          self.view.layoutIfNeeded()
        })
      }
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
//    print("qwertyui")
//    NSLayoutConstraint.activate([
//      image.widthAnchor.constraint(equalToConstant: 60),
//      image.heightAnchor.constraint(equalToConstant: 60)
//    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    image.clipsToBounds = true
    image.layer.cornerRadius = 60
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

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func createBarButton() {
    let button = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down.fill")!,
                                      style: .plain,
                                      target: self,
                                      action: #selector(editInfo))

    navigationItem.rightBarButtonItem = button
  }

  @objc func addToFavorte(_ sender: IndexedButton) {
    let index = sender.buttonIndexPath.row
    ContactsModel.contactsSourceArray.contacts[index].isFavorite.toggle()
    if   ContactsModel.contactsSourceArray.contacts[index].isFavorite == true {
      favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(
        .systemRed,
        renderingMode: .alwaysOriginal),
                              for: .normal)
      contactsModel.saveToDisk()
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart")?.withTintColor(
        .systemRed,
        renderingMode: .alwaysOriginal),
                              for: .normal)
      contactsModel.saveToDisk()
    }
  }

  @objc func editInfo(_ sender: UIBarButtonItem) {
    isEdit.toggle()
    print(isEdit)
    if isEdit == true {
      sender.image = UIImage(systemName: "e.square.fill")!
      fullName.isUserInteractionEnabled = true
      phoneNumber.isUserInteractionEnabled = true
      fullName.becomeFirstResponder()
    } else {
      sender.image = UIImage(systemName: "square.and.arrow.down.fill")!
      fullName.isUserInteractionEnabled = false
      phoneNumber.isUserInteractionEnabled = false
      fullName.resignFirstResponder()
      ContactsModel.contactsSourceArray.contacts[numberInArray].name = fullName.text!
      phoneNumber.resignFirstResponder()
      ContactsModel.contactsSourceArray.contacts[numberInArray].phoneNumber = phoneNumber.text!
      contactsModel.saveToDisk()
    }
  }

  private func formatPhoneNumber(number: String) -> String {
    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let mask = "+XXX (XX) XXX-XX-XX"
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
}

extension InfoAboutContactViewController: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if textField == fullName {
      return true
    }
    guard let text = textField.text else { return false }

    let newString = (text as NSString).replacingCharacters(in: range, with: string)
    textField.text = formatPhoneNumber(number: newString)
    return false
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == fullName {
      self.title = fullName.text
      textField.resignFirstResponder()
      phoneNumber.becomeFirstResponder()
      ContactsModel.contactsSourceArray.contacts[numberInArray].name = fullName.text!
      contactsModel.saveToDisk()
    } else {
      textField.resignFirstResponder()
      ContactsModel.contactsSourceArray.contacts[numberInArray].phoneNumber = phoneNumber.text!
      contactsModel.saveToDisk()
    }
    return true
  }
}
