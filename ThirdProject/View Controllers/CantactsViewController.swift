//
//  ViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit
import Contacts

class CantactsViewController: UIViewController {

  var contactsModel = ContactsModel()

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

    table.dataSource = self
    table.delegate = self

    switch contactsModel.authorizationStatus {
    case .notDetermined :
      addAccessButton()
    case .restricted, .denied :
      present(accessAlert, animated: true)
      addAccessButton()
    case .authorized:
        accessButton.removeFromSuperview()
        let cached = contactsModel.fetchCachedContacts()
        if cached.contacts.isEmpty {
          addAccessButton()
        }
        NSLayoutConstraint.activate([
          table.widthAnchor.constraint(equalTo: view.widthAnchor),
          table.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        self.table.reloadData()
    default : break
    }

    let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(longPress(longPressGestureRecognizer:)))
    table.addGestureRecognizer(longPressRecognizer)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    table.reloadData()
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
          title: "Действия с контактом: \(ContactsModel.contactsSourceArray.contacts[indexPath.row].name)",
          message: "Что вы хотите сделать с этим контактом?",
          preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Скопировать телефон", style: .default, handler: { _ in
          UIPasteboard.general.string = ContactsModel.contactsSourceArray.contacts[indexPath.row].phoneNumber
        }))

        alert.addAction(UIAlertAction(title: "Поделиться телефоном", style: .default, handler: { [self] _ in
          let number = ContactsModel.contactsSourceArray.contacts[indexPath.row].phoneNumber
          let activityViewController =
          UIActivityViewController(activityItems: [number],
                                   applicationActivities: nil)
          present(activityViewController, animated: true)

        }))

        alert.addAction(UIAlertAction(title: "Удалить контакт", style: .default, handler: { [self] _ in
          ContactsModel.contactsSourceArray.contacts.remove(at: indexPath.row)
          contactsModel.saveToDisk()
          table.deleteRows(at: [indexPath], with: .fade)
          if ContactsModel.contactsSourceArray.contacts.isEmpty {
            addAccessButton()
          }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
      }
    }
  }

  @objc func accessToContacts () {
    contactsModel.authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    switch contactsModel.authorizationStatus {
    case .authorized : loadContacts()
    case .notDetermined:
      contactsModel.contactStore.requestAccess(for: .contacts) { [self] access, error in
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
    contactsModel.loadContacts()
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
  }
}

extension CantactsViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ContactsModel.contactsSourceArray.contacts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = table.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath)
        as? ContactCell {
      let contact = ContactsModel.contactsSourceArray.contacts[indexPath.row]
      cell.config(model: contact, indexPath: indexPath)
      return cell
    }
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = ContactsModel.contactsSourceArray.contacts[indexPath.row]
    let viewController = InfoAboutContactViewController(
      imageItem: model.image.getImage()!,
      titleItem: model.name,
      item: model,
      indexPath: indexPath)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
