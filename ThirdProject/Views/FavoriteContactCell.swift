//
//  FavoriteViewCell.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 19.02.22.
//

import UIKit

class FavoriteContactCell: UITableViewCell {

  static var cellIdentifier = "FavoriteViewCell"
  var contactsModel = ContactsModel()

    private lazy var contactImageView: UIImageView = {
      var image = UIImageView()
      image.translatesAutoresizingMaskIntoConstraints = false
      image.backgroundColor = .systemGray3
      image.contentMode = .scaleAspectFill
      return image
    }()

    private lazy var fullNameLabel: UILabel = {
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      contentView.addSubview(phoneNumberLabel)
      contentView.addSubview(contactImageView)
      contentView.addSubview(fullNameLabel)

      NSLayoutConstraint.activate([
        fullNameLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 20),
        fullNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),

        phoneNumberLabel.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 20),
        phoneNumberLabel.topAnchor.constraint(equalTo: contactImageView.centerYAnchor, constant: -5),

        contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        contactImageView.topAnchor.constraint(equalTo: fullNameLabel.topAnchor),
        contactImageView.widthAnchor.constraint(equalToConstant: 50),
        contactImageView.heightAnchor.constraint(equalToConstant: 50)
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

    func config(model: Contact, indexPath: IndexPath) {
      phoneNumberLabel.text = model.phoneNumber
      fullNameLabel.text = model.name
      contactImageView.image = model.image.getImage()
    }
  }
