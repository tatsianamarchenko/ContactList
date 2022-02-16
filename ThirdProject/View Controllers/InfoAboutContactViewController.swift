//
//  InfoAboutContactViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class InfoAboutContactViewController: UIViewController {

  struct SettingsCellOption {
    let textField: String
    let nameOfRow: String
  }

  var sourceArray = [SettingsCellOption]()

  private lazy var image: UIImageView = {
    var image = UIImageView()
    image.layoutSubviews()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.backgroundColor = .systemGray3
    image.contentMode = .scaleAspectFit
    return image
  }()

  private lazy var table: UITableView = {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.cellIdentifier)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    view.addSubview(table)
    view.addSubview(image)
    table.dataSource = self
    table.delegate = self

    NSLayoutConstraint.activate([
      image.widthAnchor.constraint(equalToConstant: 150),
      image.heightAnchor.constraint(equalToConstant: 150),
      image.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      table.widthAnchor.constraint(equalTo: view.widthAnchor),
      table.heightAnchor.constraint(equalTo: view.heightAnchor)
    ])

    let emailButton = UIBarButtonItem(image: UIImage(systemName: "e.square.fill")!,
                                      style: .plain,
                                      target: self,
                                      action: #selector(editInfo))

    navigationItem.rightBarButtonItem = emailButton
  }

  @objc func editInfo() {
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    image.clipsToBounds = true
    image.layer.cornerRadius = 75
  }

  init(imageItem: UIImage, titleItem: String, item: Contact) {
    super.init(nibName: nil, bundle: nil)
    image.image = imageItem
    self.title = titleItem
    newConfigure(model: item)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func newConfigure(model: Contact) {
    self.sourceArray = [SettingsCellOption(textField: model.name, nameOfRow: "Имя"),
                     SettingsCellOption(textField: model.phoneNumber, nameOfRow: "Номер")
    ]
  }

}

extension InfoAboutContactViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sourceArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = table.dequeueReusableCell(withIdentifier: SettingsCell.cellIdentifier, for: indexPath)
            as? SettingsCell else {
              return UITableViewCell()
            }
    let model = sourceArray[indexPath.row]
    cell.lable.text = model.nameOfRow
    cell.textField.text = model.textField
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return image
  }
}

//По нажатию на ячейку открывается (push) экран детальной информации о контакте, на котором отображается отцентрированное и круглое фото контакта.
//Под фото расположите поля ввода, в которых отображаются фио и номер телефона. У каждого поля ввода есть title (заголовок, например: Phone Number)
//
//В nav bar есть кнопка Edit, которая по нажатию меняет своё состояние на Save и включает режим редактирования контакта.
// Пользователь может отредактировать ФИО и номер телефона. Сохраняется контакт по нажатию на кнопку Save.
//

//
//  private lazy var fullName: UITextField = {
//    var textField = UITextField()
//    textField.translatesAutoresizingMaskIntoConstraints = false
//    textField.font = UIFont.systemFont(ofSize: 20)
//    textField.textColor = .label
//    return textField
//  }()
//
//  private lazy var phoneNumber: UITextField = {
//    var textField = UITextField()
//    textField.translatesAutoresizingMaskIntoConstraints = false
//    textField.font = UIFont.systemFont(ofSize: 20)
//    textField.textAlignment = .center
//    textField.textColor = .secondaryLabel
//    return textField
//  }()
//
//  func createStack(textField: UITextField, name: String) -> UIStackView {
//    let lable = UILabel()
//    lable.text = name
//    lable.font = UIFont.systemFont(ofSize: 20)
//    textField.textColor = .label
//
//    let stack = UIStackView(arrangedSubviews: [lable, textField])
//    stack.translatesAutoresizingMaskIntoConstraints = false
//    stack.axis = .horizontal
//    stack.alignment = .leading
//    stack.backgroundColor = .systemGray6
//    stack.clipsToBounds = true
//    stack.layer.cornerRadius = 10
//    view.addSubview(stack)
//    return stack
//  }
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    view.backgroundColor = .systemBackground
//
//    let stackFullName = createStack(textField: fullName, name: "имя")
//    let stackPhoneNumber = createStack(textField: phoneNumber, name: "номер")
//
//    let mainStack = UIStackView(arrangedSubviews: [image, stackFullName, stackPhoneNumber])
//    mainStack.translatesAutoresizingMaskIntoConstraints = false
//    mainStack.axis = .vertical
//    mainStack.alignment = .center
//    view.addSubview(mainStack)
//
//    NSLayoutConstraint.activate([
//      mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//      mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//  //    stackFullName.heightAnchor.constraint(equalToConstant: 50),
//      stackFullName.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),
//
//      stackPhoneNumber.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 10),
//      stackPhoneNumber.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30),
//
//      image.widthAnchor.constraint(equalToConstant: 150),
//      image.heightAnchor.constraint(equalToConstant: 150)
//    ])
//  }
//
