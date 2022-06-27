//
//  IndexedButton.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 27.06.22.
//

import Foundation
import UIKit

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
