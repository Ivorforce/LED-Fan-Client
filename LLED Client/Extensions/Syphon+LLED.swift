//
//  Syphon+LLED.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 05.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

@objc
extension SyphonServerDirectory {
    @objc
    func server(withID id: String) -> [String: Any]? {
        return servers
            .compactMap { $0 as? [String: Any] }
            .filter { $0[SyphonServerDescriptionUUIDKey] as? String == id }
            .first
    }
}
