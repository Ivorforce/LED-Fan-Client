//
//  ArtnetProvider.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation

class ArtnetProvider {
    static let port: UInt16 = 6454
    
    var sequence: UInt8 = 0
    
    var net: Int = 0
    var subnet: Int = 0
    var universe: Int = 0

    func pack(payload: Data, offset: Int = 0) -> Data {
        var packet = Data()
        
        packet.append("Art-Net".data(using: .utf8)!)
        packet.append(0x00)
        
//        # 8 - opcode (2 x 8 low byte first)
        packet.append(0x00)
        packet.append(0x50)  // ArtDmx data packet
//        # 10 - prototocol version (2 x 8 high byte first)
        packet.append(0x00)
        packet.append(14)
//        # 12 - sequence (int 8), NULL for not implemented
        packet.append(sequence)
//        # 13 - physical port (int 8)
        packet.append(0x00)
//        # 14 - universe, (2 x 8 low byte first)
//
//        # as specified in Artnet 4
//        # Bit 3  - 0 = Universe (1-16)
//        # Bit 7  - 4 = Subnet (1-16)
//        # Bit 14 - 8 = Net (1-128)
//        # Bit 15     = 0
//        # this means 16 * 16 * 128 = 32768 universes per port
//        # a subnet is a group of 16 Universes
//        # 16 subnets will make a net, there are 128 of them
        let totalUniverse = (net << 8 | subnet << 4 | universe) + offset
        packet.append(contentsOf: totalUniverse.bytes[0...1])

//        # 16 - packet size (2 x 8 high byte first)
        packet.append(contentsOf: payload.count.bigEndian.bytes[0...1])
        packet.append(payload)

        return packet // TODO
    }
}
