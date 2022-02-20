//
//  InfoAboutContactViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class InfoAboutContactViewController: UIViewController {

private var contactsModel = ContactsModel()
 private var numberInArray = 0
 private var isEdit = false

  private lazy var contactImageView: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.backgroundColor = .systemGray3
    image.clipsToBounds = true
    image.contentMode = .scaleAspectFill
    return image
  }()

  private lazy var addToFavoriteButton: IndexedButton = {
    let button = IndexedButton(buttonIndexPath: IndexPath(index: 0))
    button.translatesAutoresizingMaskIntoConstraints = false
    button.contentMode = .scaleAspectFill
    button.addTarget(self, action: #selector(addToFavorte), for: .touchUpInside)
    return button
  }()

  private lazy var fullNameTextField: UITextField = {
    let textField = UITextField()
    configTextField(textField: textField)
    textField.keyboardType = .default
    textField.autocapitalizationType = .words
    textField.autocorrectionType = .no
    textField.placeholder = "Введите имя"
    return textField
  }()

  private lazy var phoneNumberTextField: UITextField = {
    let textField = UITextField()
    configTextField(textField: textField)
    textField.keyboardType = .phonePad
    textField.placeholder = "Введите номер"
    return textField
  }()

  private lazy var stackFullName: UIStackView = {
    let stack = createStack(textField: fullNameTextField,
                           name: NSLocalizedString("name", comment: ""))
    return stack
  }()

  private lazy var stackPhoneNumber: UIStackView = {
    let stack = createStack(textField: phoneNumberTextField,
                            name: NSLocalizedString("phoneNumber", comment: ""))
    return stack
  }()

  private lazy var mainStack: UIStackView = {
    let stack = UIStackView()
    return stack
  }()

  init(imageItem: UIImage, titleItem: String, item: Contact, indexPath: IndexPath) {
    super.init(nibName: nil, bundle: nil)
    contactImageView.image = imageItem
    fullNameTextField.text = item.name
    phoneNumberTextField.text = item.phoneNumber
    self.title = titleItem
    self.numberInArray = indexPath.row
    addToFavoriteButton.setImage(UIImage(systemName:
                                      item.isFavorite ?
                                    "heart.fill" : "heart")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                            for: .normal)
    addToFavoriteButton.buttonIndexPath = indexPath
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    phoneNumberTextField.delegate = self
    fullNameTextField.delegate = self
    createBarButton()
    mainStack = UIStackView(arrangedSubviews: [contactImageView, stackFullName,
                                                   stackPhoneNumber,
                                                   addToFavoriteButton])
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    mainStack.axis = .vertical
    mainStack.alignment = .center
    view.addSubview(mainStack)

    NSLayoutConstraint.activate([
      mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackFullName.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
      stackPhoneNumber.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
      contactImageView.widthAnchor.constraint(equalToConstant: imageSize),
      contactImageView.heightAnchor.constraint(equalToConstant: imageSize)
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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
      contactImageView.layer.cornerRadius = imageSize/2
  }

  private func configTextField (textField: UITextField) {
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont.systemFont(ofSize: textSize)
    textField.textAlignment = .center
    textField.textColor = .label
    textField.clearButtonMode = .whileEditing
    textField.isUserInteractionEnabled = false
    textField.contentMode = .center
  }

  private func createStack(textField: UITextField, name: String) -> UIStackView {
    let lable = UILabel()
    lable.text = name
    lable.font = UIFont.systemFont(ofSize: textSize)
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

  func createBarButton() {
    let saveImage = UIImage(systemName: "e.square.fill")
    guard let saveImage = saveImage else {
      return
    }
    let button = UIBarButtonItem(image: saveImage,
                                      style: .plain,
                                      target: self,
                                      action: #selector(editInfo))

    navigationItem.rightBarButtonItem = button
  }

  @objc func addToFavorte(_ sender: IndexedButton) {
    let index = sender.buttonIndexPath.row
    ContactsModel.contactsSourceArray.contacts[index].isFavorite.toggle()
    if   ContactsModel.contactsSourceArray.contacts[index].isFavorite == true {
      addToFavoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(
        .systemRed,
        renderingMode: .alwaysOriginal),
                              for: .normal)
      contactsModel.saveToDisk()
    } else {
      addToFavoriteButton.setImage(UIImage(systemName: "heart")?.withTintColor(
        .systemRed,
        renderingMode: .alwaysOriginal),
                              for: .normal)
      contactsModel.saveToDisk()
    }
  }

  @objc func editInfo(_ sender: UIBarButtonItem) {
    isEdit.toggle()
    let saveImage = UIImage(systemName: "e.square.fill")
    guard let saveImage = saveImage else {
      return
    }
    let editImage = UIImage(systemName: "square.and.arrow.down.fill")
    guard let editImage = editImage else {
      return
    }

    if isEdit == true {
      sender.image = editImage
      fullNameTextField.isUserInteractionEnabled = true
      phoneNumberTextField.isUserInteractionEnabled = true
      fullNameTextField.becomeFirstResponder()
    } else {
      sender.image = saveImage

      self.title = fullNameTextField.text

      fullNameTextField.isUserInteractionEnabled = false
      phoneNumberTextField.isUserInteractionEnabled = false
      fullNameTextField.resignFirstResponder()
      phoneNumberTextField.resignFirstResponder()

      let name = fullNameTextField.text
      if let name = name {
        ContactsModel.contactsSourceArray.contacts[numberInArray].name = name
        contactsModel.saveToDisk()
      }

      let phoneNumber = phoneNumberTextField.text
      if let phoneNumber = phoneNumber {
        ContactsModel.contactsSourceArray.contacts[numberInArray].phoneNumber = phoneNumber
        contactsModel.saveToDisk()
      }
    }
  }

  private func formatPhoneNumber(number: String) -> String {
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

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

}

extension InfoAboutContactViewController: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if textField == fullNameTextField {
      return true
    }
    guard let text = textField.text else { return false }

    let newString = (text as NSString).replacingCharacters(in: range, with: string)
    textField.text = formatPhoneNumber(number: newString)
    return false
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == fullNameTextField {
      self.title = fullNameTextField.text
      textField.resignFirstResponder()
      phoneNumberTextField.becomeFirstResponder()
      let name = fullNameTextField.text
      if let name = name {
        ContactsModel.contactsSourceArray.contacts[numberInArray].name = name
        contactsModel.saveToDisk()
      }
    } else {
      textField.resignFirstResponder()
      let phoneNumber = phoneNumberTextField.text
      if let phoneNumber = phoneNumber {
        ContactsModel.contactsSourceArray.contacts[numberInArray].phoneNumber = phoneNumber
        contactsModel.saveToDisk()
      }
    }
    return true
  }
}
