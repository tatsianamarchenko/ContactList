//
//  FavoriteViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class FavoriteViewController: UIViewController {

var arrayOfFavorite = [Contact]()

  private lazy var table: UITableView = {
    let table = UITableView()
    table.register(ContactCell.self, forCellReuseIdentifier: ContactCell.cellIdentifier)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

    override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .systemBackground
      view.addSubview(table)

      table.dataSource = self
      table.delegate = self

      NSLayoutConstraint.activate([
        table.widthAnchor.constraint(equalTo: view.widthAnchor),
        table.heightAnchor.constraint(equalTo: view.heightAnchor)
      ])
    }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    arrayOfFavorite = [Contact]()
    for index in 0..<contactsSourceArray.contacts.count {
      if contactsSourceArray.contacts[index].isFavorite {
        arrayOfFavorite.append(contactsSourceArray.contacts[index])
      }
    }
    table.reloadData()
  }

}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayOfFavorite.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = table.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath)
        as? ContactCell {
      let contact = arrayOfFavorite[indexPath.row]
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
  }
}
