//
//  ContactModel.swift
//  ThirdProject
//
//  Created by Tatsiana Marchanka on 15.02.22.
//

import Foundation
import UIKit

struct ContactsModel: Codable {
  var contactsArray: [Contact]
}

struct Contact: Codable {
  var name: String
  var phoneNumber: String
  var image: Image
}

struct Image: Codable {
    let imageData: Data?

    init(withImage image: UIImage) {
        self.imageData = image.pngData()
    }

    func getImage() -> UIImage? {
        guard let imageData = self.imageData else {
            return nil
        }
        let image = UIImage(data: imageData)

        return image
    }
}

typealias Handler<T> = (Result<T, Error>) -> Void

protocol ReadableStorage {
    func fetchValue(for key: String) throws -> Data
    func fetchValue(for key: String, handler: @escaping Handler<Data>)
}

protocol WritableStorage {
    func save(value: Data, for key: String) throws
    func save(value: Data, for key: String, handler: @escaping Handler<Data>)
}

typealias Storage = ReadableStorage & WritableStorage


enum StorageError: Error {
    case notFound
    case cantWrite(Error)
}

class DiskStorage {
    private let queue: DispatchQueue
    private let fileManager: FileManager
    private let path: URL

    init(
        path: URL,
        queue: DispatchQueue = .init(label: "DiskCache.Queue"),
        fileManager: FileManager = FileManager.default
    ) {
        self.path = path
        self.queue = queue
        self.fileManager = fileManager
    }
}


extension DiskStorage: WritableStorage {
    func save(value: Data, for key: String) throws {
        let url = path.appendingPathComponent(key)
        do {
            try self.createFolders(in: url)
            try value.write(to: url, options: .atomic)
        } catch {
            throw StorageError.cantWrite(error)
        }
    }

    func save(value: Data, for key: String, handler: @escaping Handler<Data>) {
        queue.async {
            do {
                try self.save(value: value, for: key)
                handler(.success(value))
            } catch {
                handler(.failure(error))
            }
        }
    }
}

extension DiskStorage {
    private func createFolders(in url: URL) throws {
        let folderUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
}



extension DiskStorage: ReadableStorage {
    func fetchValue(for key: String) throws -> Data {
        let url = path.appendingPathComponent(key)
        guard let data = fileManager.contents(atPath: url.path) else {
            throw StorageError.notFound
        }
        return data
    }

    func fetchValue(for key: String, handler: @escaping Handler<Data>) {
        queue.async {
            handler(Result { try self.fetchValue(for: key) })
        }
    }
}




class CodableStorage {
  private let storage: DiskStorage
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder

  init(
    storage: DiskStorage,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.storage = storage
    self.decoder = decoder
    self.encoder = encoder
  }

  func fetch<T: Decodable>(for key: String) throws -> T {
    let data = try storage.fetchValue(for: key)
    return try decoder.decode(T.self, from: data)
  }

  func save<T: Encodable>(_ value: T, for key: String) throws {
    let data = try encoder.encode(value)
    try storage.save(value: data, for: key)
  }
}

struct Timeline: Codable {
    let tweets: [String]
}
