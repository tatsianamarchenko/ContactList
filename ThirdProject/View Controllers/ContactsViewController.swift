//
//  ViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {

  private let contactsModel = ContactsModel()

  private lazy var spiner: UIActivityIndicatorView = {
    var spiner = UIActivityIndicatorView(style: .large)
    spiner.translatesAutoresizingMaskIntoConstraints = false
    return spiner
  }()

  private lazy var accessButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(NSLocalizedString("load", comment: ""), for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: textSize, weight: .bold)
    button.tintColor = contactsTextColor
    button.backgroundColor = backgroundColor
    button.layer.masksToBounds = true
    button.layer.cornerRadius = generalCornerRadius
    button.addTarget(self, action: #selector(accessToContacts), for: .touchUpInside)
    return button
  }()

  private lazy var contactsViewTable: UITableView = {
    let table = UITableView()
    table.register(ContactCell.self, forCellReuseIdentifier: ContactCell.cellIdentifier)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  private lazy var accessAlertController: UIAlertController = {
    let alert = UIAlertController(title: NSLocalizedString("accessDenied", comment: ""),
                                  message:
                                    NSLocalizedString("accessMessage", comment: ""),
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("access", comment: ""), style: .default, handler: { _ in
      if let appSettings = URL(string: UIApplication.openSettingsURLString),
         UIApplication.shared.canOpenURL(appSettings) {
        UIApplication.shared.open(appSettings)
      }
    }))
    alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
    return alert
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(accessButton)
    view.addSubview(contactsViewTable)
    view.addSubview(spiner)

    contactsViewTable.dataSource = self
    contactsViewTable.delegate = self

    switch contactsModel.authorizationStatus {
    case .notDetermined :
      addAccessButton()
    case .restricted, .denied :
      present(accessAlertController, animated: true)
      addAccessButton()
    case .authorized:
      accessButton.removeFromSuperview()
      let cached = contactsModel.fetchCachedContacts()
      if cached.contacts.isEmpty {
        addAccessButton()
      }
      NSLayoutConstraint.activate([
        contactsViewTable.topAnchor.constraint(equalTo: view.topAnchor),
        contactsViewTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        contactsViewTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        contactsViewTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
      ])
      self.contactsViewTable.reloadData()
    default : break
    }

    let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(longPress(longPressGestureRecognizer:)))
    contactsViewTable.addGestureRecognizer(longPressRecognizer)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    contactsViewTable.reloadData()
  }

  func addAccessButton () {
    view.addSubview(accessButton)
    NSLayoutConstraint.activate([
      accessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      accessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      accessButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplierForBotton)
    ])
  }

  @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
    if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
      let touchPoint = longPressGestureRecognizer.location(in: self.contactsViewTable)
      if let indexPath = contactsViewTable.indexPathForRow(at: touchPoint) {
        let alert = UIAlertController(
          title: "\(ContactsModel.contactsSourceArray.contacts[indexPath.row].name)",
          message: "\(ContactsModel.contactsSourceArray.contacts[indexPath.row].phoneNumber)",
          preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("copy", comment: ""), style: .default, handler: { _ in
          UIPasteboard.general.string = ContactsModel.contactsSourceArray.contacts[indexPath.row].phoneNumber
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("share", comment: ""),
                                      style: .default,
                                      handler: { [self] _ in
          let number = ContactsModel.contactsSourceArray.contacts[indexPath.row].phoneNumber
          let activityViewController =
          UIActivityViewController(activityItems: [number],
                                   applicationActivities: nil)
          DispatchQueue.main.async {
            present(activityViewController, animated: true)
          }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""),
                                      style: .default,
                                      handler: { [self] _ in
          ContactsModel.contactsSourceArray.contacts.remove(at: indexPath.row)
          contactsModel.saveToDisk()
          contactsViewTable.beginUpdates()
          contactsViewTable.deleteRows(at: [indexPath], with: .fade)
          contactsViewTable.endUpdates()
          if ContactsModel.contactsSourceArray.contacts.isEmpty {
            addAccessButton()
          }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
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
      present(accessAlertController, animated: true)
    default:
      break
    }
  }

  func loadContacts() {
    DispatchQueue.global(qos: .userInteractive).async { [self] in
      DispatchQueue.main.async {
        NSLayoutConstraint.activate([
          spiner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          spiner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spiner.startAnimating()
      }
      contactsModel.loadContacts()
      DispatchQueue.main.async {
        spiner.stopAnimating()
        spiner.removeFromSuperview()
        NSLayoutConstraint.deactivate([
          spiner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          spiner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
          contactsViewTable.topAnchor.constraint(equalTo: view.topAnchor),
          contactsViewTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          contactsViewTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          contactsViewTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        contactsViewTable.reloadData()
      }
    }
    DispatchQueue.main.async { [self] in
      accessButton.removeFromSuperview()
      NSLayoutConstraint.deactivate([
        accessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        accessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        accessButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplierForBotton)
      ])
    }
  }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ContactsModel.contactsSourceArray.contacts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = contactsViewTable.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath)
        as? ContactCell {
      let contact = ContactsModel.contactsSourceArray.contacts[indexPath.row]
      cell.config(model: contact, indexPath: indexPath)
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return heightForRow
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = ContactsModel.contactsSourceArray.contacts[indexPath.row]
    guard let image =  model.image.getImage() else {
      return
    }
    let viewController = InfoAboutContactViewController(
      imageItem: image,
      titleItem: model.name,
      item: model,
      indexPath: indexPath)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
