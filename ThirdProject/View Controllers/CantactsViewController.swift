//
//  ViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit
import Contacts

class CantactsViewController: UIViewController {

  static var indexAction = 0
  var contactStore = CNContactStore()
  var contacts = [CNContact]()
  static var array = [Contact]()
  var authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

  var menuAlertController: UIAlertController = {
    var alert = UIAlertController(title: "Действия с контактом",
                                  message: "Что вы хотите сделать с этим контактом?",
                                  preferredStyle: .actionSheet)
    var copy = UIAlertAction(title: "Скопировать телефон", style: .default) { _ in
      UIPasteboard.general.string = CantactsViewController.array[CantactsViewController.indexAction].phoneNumber
    }
    var share = UIAlertAction(title: "Поделиться телефоном", style: .default, handler: nil)
    var delete = UIAlertAction(title: "Удалить контакт", style: .default) { _ in
    }
    var cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(copy)
    alert.addAction(share)
    alert.addAction(delete)
    alert.addAction(cancel)
    //Долгое нажатие на ячейку контакта показывает Alert c именем контакта в заголовке и с четырьмя кнопками:
    //Скопировать телефон (копирует номер телефона в буфер обмена)
    //Поделиться телефоном (открывает UIActivityViewController)
    //Удалить контакт (destructive operation, удаляет контакт из списка)
    //Cancel (закрывает alert)
    return alert
  }()

  private lazy var accessButton: UIButton = {
    var button = UIButton(type: .roundedRect)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Загрузить контакты", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    button.setTitle("Tapped", for: .highlighted )
    button.backgroundColor = .systemGray6
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 10
    button.addTarget(self, action: #selector(accessToContacts), for: .touchUpInside)
    return button
  }()

  private lazy var table: UITableView = {
    let table = UITableView()
    table.register(ContactCell.self, forCellReuseIdentifier: ContactCell.cellIdentifier)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  private lazy var accessAlert: UIAlertController = {
    var alert = UIAlertController(title: "Доступ запрещен",
                                  message: "Для работы приложения необходимо разрешить доступ к контактам",
                                  preferredStyle: .alert)
    var cancel = UIAlertAction(title: "отмена", style: .cancel, handler: nil)
    alert.addAction(cancel)
    return alert
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    view.addSubview(accessButton)
    view.addSubview(table)

    table.dataSource = self
    table.delegate = self

    NSLayoutConstraint.activate([
      accessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      accessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      accessButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
    ])
    switch authorizationStatus {
    case .restricted, .denied :
      present(accessAlert, animated: true)
    case .authorized:
      loadContacts()
    default : break
    }

    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
    table.addGestureRecognizer(longPressRecognizer)
  }

  @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
    if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {

      let touchPoint = longPressGestureRecognizer.location(in: self.view)
      if let indexPath = table.indexPathForRow(at: touchPoint) {
        present(menuAlertController, animated: true)
        print("longPress: \(indexPath.row-2)")
        CantactsViewController.indexAction = indexPath.row-2
      }
    }
  }

  @objc func accessToContacts () {
    authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    switch authorizationStatus {
    case .notDetermined:
      contactStore.requestAccess(for: .contacts) { [self] access, error in
        if access {
          loadContacts()
        } else {
          // present(accessAlert, animated: true)
          print(error ?? "Ошибка доступа")
        }
      }
    case .restricted, .denied :
      present(accessAlert, animated: true)
    case .authorized:
      loadContacts()
    default:
      break
    }
  }

  func loadContacts() {
    do {
      contacts = [CNContact]()
      print(Helper.path)
      let keysTofetch = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor]
      let request = CNContactFetchRequest(keysToFetch: keysTofetch)
      try contactStore.enumerateContacts(with: request, usingBlock: { cnContact, _ in
        self.contacts.append(cnContact)
      })
      for contact in 0..<(self.contacts.count) {

        var image = UIImage(systemName: "person.fill")
        if contacts[contact].isKeyAvailable(CNContactImageDataKey) {
          if let buf = contacts[contact].imageData {
            image = UIImage(data: buf)
          }
        }

        let contactItem = Contact(name: contacts[contact].givenName + " " + contacts[contact].familyName,
                                  phoneNumber: (contacts[contact].phoneNumbers.first?.value.stringValue)!,
                                  image: Image(withImage: image!))
        CantactsViewController.array.append(contactItem)
        do {
          try Helper.storage.save(CantactsViewController.array, for: "contactItem")
         // print(contactItem)
        } catch {
          print(error)
        }
      }

      DispatchQueue.main.async { [self] in
        NSLayoutConstraint.deactivate([
          accessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          accessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
          accessButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])

        NSLayoutConstraint.activate([
          table.widthAnchor.constraint(equalTo: view.widthAnchor),
          table.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        self.table.reloadData()
      }
    } catch {
      print(error)
    }
  }
}

extension CantactsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CantactsViewController.array.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = table.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath)
        as? ContactCell {
      let contact = CantactsViewController.array[indexPath.row]
      cell.config(model: contact)
      return cell
    }
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let numberInArray = indexPath.row
    let model = CantactsViewController.array[indexPath.row]
    let viewController = InfoAboutContactViewController(
      imageItem: model.image.getImage()!,
      titleItem: model.name,
      item: model, numberInArray: numberInArray)
    navigationController?.pushViewController(viewController, animated: true)
  }

  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    .delete
  }

  func tableView(_ tableView: UITableView,
                 commit editingStyle: UITableViewCell.EditingStyle,
                 forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      CantactsViewController.array.remove(at: indexPath.row)
      do {
        try Helper.storage.save(CantactsViewController.array, for: "contactItem")
      } catch {
        print(error)
      }
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}

//При первом запуске приложения посреди экрана отображается кнопка “Загрузить контакты”, по нажатию на которую запрашивается доступ к контактной книге и все контакты загружаются в приложение.
//Каждый контакт - отдельная ячейка таблицы, у которой есть:

//Номер телефона (отображается отформатированным: +375 29 123 45 67)
//Иконка favourite: контакт добавлен в избранное (иконка сердечка).
//Список контактов сохраняется между перезапусками приложения в файл на устройстве пользователя (используйте Codable для модели контакта)
//
//В nav bar есть кнопка Edit, которая по нажатию меняет своё состояние на Save и включает режим редактирования контакта.
// Пользователь может отредактировать ФИО и номер телефона. Сохраняется контакт по нажатию на кнопку Save.
//
//Долгое нажатие на ячейку контакта показывает Alert c именем контакта в заголовке и с четырьмя кнопками:
//Скопировать телефон (копирует номер телефона в буфер обмена)
//Поделиться телефоном (открывает UIActivityViewController)
//Удалить контакт (destructive operation, удаляет контакт из списка)
//Cancel (закрывает alert)
//Если пользователь удалил все контакты (список пустой), то ему снова отображается кнопка “Загрузить контакты”
//
//Обработать ситуацию, когда пользователь запретил доступ к контактной книге: вывести сообщение
//посередине экрана с просьбой предоставить доступ к контактной книге и кнопкой, которая перебрасывает пользователя в настройки вашего приложения.
// try contactStore.enumerateContacts(with: request, usingBlock: {cnContact, error in
//        if cnContact.isKeyAvailable(CNContactEmailAddressesKey) {
//          for entity in cnContact.emailAddresses {
//           let strValue = entity.value as String
//
//    //  if entity.label == CNLabelHome && !strValue.isEmpty {
//        self.contacts.append(cnContact)
//       // break
//    //  }
//   // }
//   }
// })

//    CNContactStore().requestAccess(for: .contacts) { [self]success, error in
//      guard success else {
//        print(error)
//        return
//      }
