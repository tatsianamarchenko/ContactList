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

  private lazy var favoriteButton: UIButton = {
    var favoriteButton = UIButton()
    favoriteButton.translatesAutoresizingMaskIntoConstraints = false
    favoriteButton.setImage(UIImage(systemName:
                                      CantactsViewController.array[numberInArray].isFavorite ?
                                    "heart.fill" : "heart")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                            for: .normal)
    favoriteButton.contentMode = .scaleAspectFill
    favoriteButton.addTarget(self, action: #selector(addToFavorte), for: .touchUpInside)
    return favoriteButton
  }()

  @objc func addToFavorte() {
    CantactsViewController.array[numberInArray].isFavorite.toggle()
    if   CantactsViewController.array[numberInArray].isFavorite == true {
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
    return textField
  }()

  private lazy var phoneNumber: UITextField = {
    var textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont.systemFont(ofSize: 20)
    textField.textAlignment = .center
    textField.textColor = .secondaryLabel
    textField.isUserInteractionEnabled = false
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
    let emailButton = UIBarButtonItem(image: isEdit ? UIImage(systemName: "square.and.arrow.down.fill")! : UIImage(systemName: "e.square.fill")!,
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

  init(imageItem: UIImage, titleItem: String, item: Contact, numberInArray: Int) {
    super.init(nibName: nil, bundle: nil)
    image.image = imageItem
    fullName.text = item.name
    phoneNumber.text = item.phoneNumber
    self.title = titleItem
    self.numberInArray = numberInArray
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
      CantactsViewController.array[numberInArray].name = fullName.text!
      saveToArray()
      phoneNumber.isUserInteractionEnabled = false
      phoneNumber.resignFirstResponder()
      CantactsViewController.array[numberInArray].phoneNumber = phoneNumber.text!
      saveToArray()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func saveToArray () {
    do {
      try Helper.storage.save(CantactsViewController.array, for: "contactItem")
    } catch {
      print(error)
    }
  }

}
// В nav bar есть кнопка Edit, которая по нажатию меняет своё состояние на Save и включает режим редактирования контакта.
// Пользователь может отредактировать ФИО и номер телефона. Сохраняется контакт по нажатию на кнопку Save.
