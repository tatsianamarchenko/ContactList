//
//  Helper.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 16.02.22.
//

import Foundation

class Helper {
 static let path = URL(fileURLWithPath: NSTemporaryDirectory())
 static let disk = DiskStorage(path: URL(fileURLWithPath: NSTemporaryDirectory()))
 static let storage = CodableStorage(storage: disk)
//  static let cached = try storage.fetch(for: "contactItem")
}
