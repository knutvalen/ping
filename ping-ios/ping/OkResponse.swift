//
//  OkResponse.swift
//  ping
//
//  Created by Knut Valen on 23/05/2018.
//  Copyright © 2018 Knut Valen. All rights reserved.
//

import Foundation

class OkResponse: Codable {
    
    let status: Int
    let ok: Bool
    let message: String?
    
    enum CodingKeys: CodingKey {
        case status
        case ok
        case message
    }
    
    init(status: Int, ok: Bool, message: String) {
        self.status = status
        self.ok = ok
        self.message = message
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
    
    static func deSerialize(data: Data) -> OkResponse? {
        let decoder = JSONDecoder()
        return try? decoder.decode(OkResponse.self, from: data)
    }
    
    // MARK: - Codable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(ok, forKey: .ok)
        try container.encode(message, forKey: .message)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Int.self, forKey: .status)
        ok = try container.decode(Bool.self, forKey: .ok)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}
