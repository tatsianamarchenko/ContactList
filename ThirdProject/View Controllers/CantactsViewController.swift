//
//  ViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit
import Contacts

var contactsSourceArray = Contacts(contacts: [Contact]())

class CantactsViewController: UIViewController {

  var contactStore = CNContactStore()
  var contacts = [CNContact]()
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
                                  message: "Для работы приложения необходимо разрешить доступ к контактам (перейдите в настройки приложения)",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Разрешить доступ", style: .default, handler: { _ in
      if let appSettings = URL(string: UIApplication.openSettingsURLString),
         UIApplication.shared.canOpenURL(appSettings) {
        UIApplication.shared.open(appSettings)
      }
    }))
    alert.addAction(UIAlertAction(title: "Oтмена", style: .cancel, handler: nil))
    return alert
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    view.addSubview(accessButton)
    view.addSubview(table)
    if contactsSourceArray.contacts.isEmpty {print("isEmpty")}
    table.dataSource = self
    table.delegate = self

    switch authorizationStatus {
    case .notDetermined, .restricted, .denied :
      addAccessButton()
    case .authorized:
      do {
        accessButton.removeFromSuperview()
        print(Helper.path)
        let cached: Contacts = try Helper.storage.fetch(for: "contactItem")
        print(cached.contacts.count)
        if cached.contacts.isEmpty {
          addAccessButton()
        }
        for index in 0..<cached.contacts.count {
          contactsSourceArray.contacts.append(cached.contacts[index])
          print(cached.contacts[index])
        }
        NSLayoutConstraint.activate([
          table.widthAnchor.constraint(equalTo: view.widthAnchor),
          table.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        self.table.reloadData()
      } catch {
        addAccessButton()
        print(error)
      }
    default : break
    }

    let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(longPress(longPressGestureRecognizer:)))
    table.addGestureRecognizer(longPressRecognizer)
  }

  func addAccessButton () {
    view.addSubview(accessButton)
    NSLayoutConstraint.activate([
      accessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      accessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      accessButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
    ])
  }

  @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
    if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
      let touchPoint = longPressGestureRecognizer.location(in: self.table)
      if let indexPath = table.indexPathForRow(at: touchPoint) {
        let alert = UIAlertController(
          title: "Действия с контактом: \(contactsSourceArray.contacts[indexPath.row].name)",
          message: "Что вы хотите сделать с этим контактом?",
          preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Скопировать телефон", style: .default, handler: { _ in
          UIPasteboard.general.string = contactsSourceArray.contacts[indexPath.row].phoneNumber
        }))

        alert.addAction(UIAlertAction(title: "Поделиться телефоном", style: .default, handler: { [self] _ in
          let number = contactsSourceArray.contacts[indexPath.row].phoneNumber
          let activityViewController =
          UIActivityViewController(activityItems: [number],
                                   applicationActivities: nil)
          present(activityViewController, animated: true)

        }))

        alert.addAction(UIAlertAction(title: "Удалить контакт", style: .default, handler: { [self] _ in
          contactsSourceArray.contacts.remove(at: indexPath.row)
          saveToDisk()
          table.deleteRows(at: [indexPath], with: .fade)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
      }
    }
  }

  @objc func accessToContacts () {
    authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    switch authorizationStatus {
    case .authorized : loadContacts()
    case .notDetermined:
      contactStore.requestAccess(for: .contacts) { [self] access, error in
        if access {
          loadContacts()
        } else {
          print(error ?? "Ошибка доступа")
        }
      }
    case .restricted, .denied :
      present(accessAlert, animated: true)
    default:
      break
    }
  }

  func loadContacts() {
    do {
      contacts = [CNContact]()
      print(Helper.path)
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
        var image = UIImage(systemName: "person.fill")
        if contacts[contact].isKeyAvailable(CNContactImageDataKey) {
          if let ima = contacts[contact].imageData {
            image = UIImage(data: ima)
          }
        }

        let contactItem = Contact(name: contacts[contact].givenName + " " + contacts[contact].familyName,
                                  phoneNumber: (contacts[contact].phoneNumbers.first?.value.stringValue)!,
                                  image: Image(withImage: image!))
        contactsSourceArray.contacts.append(contactItem)
        saveToDisk()
      }
      DispatchQueue.main.async { [self] in

        accessButton.removeFromSuperview()

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

  func saveToDisk() {
    do {
      try Helper.storage.save(contactsSourceArray, for: "contactItem")
    } catch {
      print(error)
    }
  }

}

extension CantactsViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contactsSourceArray.contacts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = table.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath)
        as? ContactCell {
      let contact = contactsSourceArray.contacts[indexPath.row]
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
    let model = contactsSourceArray.contacts[indexPath.row]
    let viewController = InfoAboutContactViewController(
      imageItem: model.image.getImage()!,
      titleItem: model.name,
      item: model, numberInArray: numberInArray)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

//Список контактов
//
//Экран с navigation bar (локализированный заголовок)
//
//При первом запуске приложения посреди экрана отображается кнопка “Загрузить контакты”, по нажатию на которую запрашивается доступ к контактной книге и все контакты загружаются в приложение.
//Каждый контакт - отдельная ячейка таблицы, у которой есть:
//
//Фотография (если фото нет, то установить любую картинку по умолчанию на ваш вкус)
//ФИО
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
//Обработать ситуацию, когда пользователь запретил доступ к контактной книге:
// вывести сообщение посередине экрана с просьбой предоставить доступ к контактной книге и кнопкой, которая перебрасывает пользователя в настройки вашего приложения.
//
//Любимые контакты
//
//Отображаются только те контакты, которые пользователь пометил как любимые. Список любимых обновляется моментально без перезахода в приложение.
// Если пользователь удалил контакт на списке контактов, то он пропадает из списка любимых.
