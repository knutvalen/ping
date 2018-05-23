//
//  Login.swift
//  ping
//
//  Created by Knut Valen on 23/05/2018.
//  Copyright © 2018 Knut Valen. All rights reserved.
//

import Foundation
import os.log

class Login: Codable {
    
    // MARK: - Properties
    
    static let shared = Login()
    var username: String
    
    enum CodingKeys: CodingKey {
        case username
    }
    
    // MARK: - Archiving paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Login")
    
    // MARK: - Initialization
    
    init() {
        self.username = "foobar"
    }
    
    init(username: String) {
        self.username = username
    }
    
    // MARK: - Public functions
    
    func toString() -> String? {
        guard let data = self.serialize() else {
            return nil
        }
        
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func serialize() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    static func deSerialize(data: Data) -> Login? {
        let decoder = JSONDecoder()
        return try? decoder.decode(Login.self, from: data)
    }
    
    // MARK: - Codable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
    }
}
