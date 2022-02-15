//
//  ViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit
import Contacts

class CantactsViewController: UIViewController {

  var contactStore = CNContactStore()
  var contacts = [CNContact]()
  var array = [Contact]()
  var authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

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

      let path = URL(fileURLWithPath: NSTemporaryDirectory())
      print(path)
      let disk = DiskStorage(path: path)
      let storage = CodableStorage(storage: disk)

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
        let contactItem = Contact(name: contacts[contact].givenName,
                                    phoneNumber: (contacts[contact].phoneNumbers.first?.value.stringValue)!)
        array.append(contactItem)

          do {
            try storage.save(array, for: "contactItem")
            print(contactItem)
          //  let cached: Contact = try storage.fetch(for: "contactItem")
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
    return contacts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = table.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath)
        as? ContactCell {
      let contact = contacts[indexPath.row]

      var fullName = "Имя не установлено"
      if contact.areKeysAvailable([CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]) {
        if let buf = CNContactFormatter.string(from: contact, style: .fullName) {
          fullName = buf
        }
      }
      cell.fullName.text = fullName

//      var phoneNumber = "Телефон не указан"
//      if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
//        if let buf = contact.phoneNumbers.first {
//          phoneNumber = buf.label ?? contact.phoneNumbers.last?.label ?? "lol"
//        }
//      }
//      cell.phoneNumber.text = phoneNumber
      let number = contact.phoneNumbers[0].value.stringValue
      cell.phoneNumber.text = number

      var image = UIImage(systemName: "person.fill")
      if contact.isKeyAvailable(CNContactImageDataKey) {
        if let buf = contact.imageData {
          image = UIImage(data: buf)
        }
      }
      cell.image.image = image
      return cell
    }
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let contact = contacts[indexPath.row]
    var image = UIImage(systemName: "person.fill")
    if contact.isKeyAvailable(CNContactImageDataKey) {
      if let buf = contact.imageData {
        image = UIImage(data: buf)
      }
    }
   let viewController = InfoAboutContactViewController(
      imageItem: image!,
      titleItem: contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName,
      descriptionItem: contacts[indexPath.row].phoneNumbers[0].value.stringValue)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

//У каждого таба должна быть иконка и текст. Иконка меняется, если таб. бар выбран (например, заливается цветом). Текст таба локализирован (ru, en)
//Дополнительно можно сделать анимацию выбора таба (иконка подрагивает).

//При первом запуске приложения посреди экрана отображается кнопка “Загрузить контакты”, по нажатию на которую запрашивается доступ к контактной книге и все контакты загружаются в приложение.
//Каждый контакт - отдельная ячейка таблицы, у которой есть:

//Номер телефона (отображается отформатированным: +375 29 123 45 67)
//Иконка favourite: контакт добавлен в избранное (иконка сердечка).
//Список контактов сохраняется между перезапусками приложения в файл на устройстве пользователя (используйте Codable для модели контакта)
//
//По нажатию на ячейку открывается (push) экран детальной информации о контакте, на котором отображается отцентрированное и круглое фото контакта.
//Под фото расположите поля ввода, в которых отображаются фио и номер телефона. У каждого поля ввода есть title (заголовок, например: Phone Number)
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
//
// Любимые контакты
//
// Отображаются только те контакты, которые пользователь пометил как любимые. Список любимых
// обновляется моментально без перезахода в приложение. Если пользователь удалил контакт на списке контактов, то он пропадает из списка любимых.

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
