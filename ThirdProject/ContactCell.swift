//
//  ContactCell.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class ContactCell: UITableViewCell {

  var image: UIImageView = {
    var image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.backgroundColor = .systemGray3
    image.contentMode = .scaleAspectFill
    return image
  }()
  
  var fullName: UILabel = {
    var title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = UIFont.systemFont(ofSize: 20)
    title.textColor = .label
    return title
  }()
  
  var phoneNumber: UILabel = {
    var descrip = UILabel()
    descrip.translatesAutoresizingMaskIntoConstraints = false
    descrip.font = UIFont.systemFont(ofSize: 16)
    descrip.textColor = .secondaryLabel
    return descrip
  }()

  static var cellIdentifier = "ContactCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(phoneNumber)
    contentView.addSubview(image)
    contentView.addSubview(fullName)

    NSLayoutConstraint.activate([
      fullName.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
      fullName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),

      phoneNumber.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
      phoneNumber.topAnchor.constraint(equalTo: image.centerYAnchor, constant: -5),

      image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      image.topAnchor.constraint(equalTo: fullName.topAnchor),
      image.widthAnchor.constraint(equalToConstant: 50),
      image.heightAnchor.constraint(equalToConstant: 50)
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    image.layer.masksToBounds = true
    image.layer.cornerRadius = 25
  }

//  func config(model : Model) {
//    phoneNumber.text = model.descriprion
//    fullName.text = model.title
//    image.image = model.image
//  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
