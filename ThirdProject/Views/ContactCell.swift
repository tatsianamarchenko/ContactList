//
//  ContactCell.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class ContactCell: UITableViewCell {

var contactsModel = ContactsModel()

  private lazy var image: UIImageView = {
    var image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.backgroundColor = .systemGray3
    image.contentMode = .scaleAspectFill
    return image
  }()

  private lazy  var fullName: UILabel = {
    var title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = UIFont.systemFont(ofSize: 20)
    title.textColor = .label
    return title
  }()

  private lazy  var phoneNumber: UILabel = {
    var descrip = UILabel()
    descrip.translatesAutoresizingMaskIntoConstraints = false
    descrip.font = UIFont.systemFont(ofSize: 16)
    descrip.textColor = .secondaryLabel
    return descrip
  }()

  private lazy var favoriteButton: IndexedButton = {
    var favoriteButton = IndexedButton(buttonIndexPath: IndexPath(index: 0))
    favoriteButton.translatesAutoresizingMaskIntoConstraints = false
    favoriteButton.contentMode = .scaleAspectFill
    favoriteButton.addTarget(self, action: #selector(addToFavorte), for: .touchUpInside)
    return favoriteButton
  }()

  @objc func addToFavorte(_ sender: IndexedButton) {
    let index = sender.buttonIndexPath.row
    ContactsModel.contactsSourceArray.contacts[index].isFavorite.toggle()
    if   ContactsModel.contactsSourceArray.contacts[index].isFavorite == true {
      favoriteButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(
        .systemRed,
        renderingMode: .alwaysOriginal),
                              for: .normal)
      contactsModel.saveToDisk()
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart")?.withTintColor(.systemRed,
                                                                          renderingMode: .alwaysOriginal), for: .normal)
      contactsModel.saveToDisk()
    }
  }

  static var cellIdentifier = "ContactCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(phoneNumber)
    contentView.addSubview(image)
    contentView.addSubview(fullName)
    contentView.addSubview(favoriteButton)

    NSLayoutConstraint.activate([
      fullName.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
      fullName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),

      phoneNumber.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
      phoneNumber.topAnchor.constraint(equalTo: image.centerYAnchor, constant: -5),

      image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      image.topAnchor.constraint(equalTo: fullName.topAnchor),
      image.widthAnchor.constraint(equalToConstant: 50),
      image.heightAnchor.constraint(equalToConstant: 50),

      favoriteButton.topAnchor.constraint(equalTo: image.topAnchor, constant: 5),
      favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    image.layer.masksToBounds = true
    image.layer.cornerRadius = 25
  }

  func config(model: Contact, indexPath: IndexPath) {
    phoneNumber.text = model.phoneNumber
    fullName.text = model.name
    image.image = model.image.getImage()
    favoriteButton.setImage(UIImage(systemName:
                                         model.isFavorite ?
                                    "heart.fill" : "heart")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                            for: .normal)
    favoriteButton.buttonIndexPath = indexPath
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class IndexedButton: UIButton {

    var buttonIndexPath: IndexPath

    init(buttonIndexPath: IndexPath) {
        self.buttonIndexPath = buttonIndexPath
      super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
