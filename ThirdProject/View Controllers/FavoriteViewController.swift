//
//  FavoriteViewController.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class FavoriteViewController: UIViewController {

  var arrayOfFavorite = [Contact]()

  private lazy var favoriteViewTable: UITableView = {
    let table = UITableView()
    table.register(FavoriteContactCell.self, forCellReuseIdentifier: FavoriteContactCell.cellIdentifier)
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    view.addSubview(favoriteViewTable)

    favoriteViewTable.dataSource = self
    favoriteViewTable.delegate = self

    NSLayoutConstraint.activate([
      favoriteViewTable.topAnchor.constraint(equalTo: view.topAnchor),
      favoriteViewTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      favoriteViewTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      favoriteViewTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    arrayOfFavorite = [Contact]()
    for index in 0..<ContactsModel.contactsSourceArray.contacts.count
    where ContactsModel.contactsSourceArray.contacts[index].isFavorite {
      arrayOfFavorite.append(ContactsModel.contactsSourceArray.contacts[index])
    }
    favoriteViewTable.reloadData()
  }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayOfFavorite.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = favoriteViewTable.dequeueReusableCell(withIdentifier: FavoriteContactCell.cellIdentifier,
                                                        for: indexPath)
        as? FavoriteContactCell {
      let contact = arrayOfFavorite[indexPath.row]
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
  }
}
