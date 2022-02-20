//
//  ContactCell.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class ContactCell: UITableViewCell {

  static var cellIdentifier = "ContactCell"
  var contactsModel = ContactsModel()

  private lazy var contactImageView: UIImageView = {
    var image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.backgroundColor = .systemGray3
    image.contentMode = .scaleAspectFill
    return image
  }()

  private lazy  var fullNameLabel: UILabel = {
    var title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = UIFont.systemFont(ofSize: textSize)
    title.textColor = .label
    return title
  }()

  private lazy var phoneNumberLabel: UILabel = {
    var descrip = UILabel()
    descrip.translatesAutoresizingMaskIntoConstraints = false
    descrip.font = UIFont.systemFont(ofSize: textSize)
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

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(phoneNumberLabel)
    contentView.addSubview(contactImageView)
    contentView.addSubview(fullNameLabel)
    contentView.addSubview(favoriteButton)

    NSLayoutConstraint.activate([
      fullNameLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 20),
      fullNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),

      phoneNumberLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 20),
      phoneNumberLabel.topAnchor.constraint(equalTo: contactImageView.centerYAnchor, constant: -5),

      contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      contactImageView.topAnchor.constraint(equalTo: fullNameLabel.topAnchor),
      contactImageView.widthAnchor.constraint(equalToConstant: 50),
      contactImageView.heightAnchor.constraint(equalToConstant: 50),

      favoriteButton.topAnchor.constraint(equalTo: contactImageView.topAnchor, constant: 5),
      favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contactImageView.layer.masksToBounds = true
    contactImageView.layer.cornerRadius = 25
  }

  @objc func addToFavorte(_ sender: IndexedButton) {
    let index = sender.buttonIndexPath.row
    ContactsModel.contactsSourceArray.contacts[index].isFavorite.toggle()
    print( ContactsModel.contactsSourceArray.contacts[index].name)
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

  func config(model: Contact, indexPath: IndexPath) {
    phoneNumberLabel.text = model.phoneNumber
    fullNameLabel.text = model.name
    contactImageView.image = model.image.getImage()
    favoriteButton.setImage(UIImage(systemName:
                                      model.isFavorite ?
                                    "heart.fill" : "heart")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                            for: .normal)
    favoriteButton.buttonIndexPath = indexPath
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
