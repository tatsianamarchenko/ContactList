//
//  SettingsCell.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import UIKit

class SettingsCell: UITableViewCell {

  var lable: UILabel = {
    var title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = UIFont.systemFont(ofSize: 20)
    title.textColor = .label
    return title
  }()

  var textField: UITextField = {
    var textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.font = UIFont.systemFont(ofSize: 20)
    textField.textColor = .label
    textField.isUserInteractionEnabled = false
    return textField
  }()

  static var cellIdentifier = "SettingsCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(lable)
    contentView.addSubview(textField)

    NSLayoutConstraint.activate([
      lable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      lable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

      textField.leadingAnchor.constraint(equalTo: lable.trailingAnchor, constant: 20),
      textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }


//  func config(model : String) {
//    phoneNumber.text = model.descriprion
//    fullName.text = model.title
//  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
