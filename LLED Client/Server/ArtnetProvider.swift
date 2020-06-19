//
//  ArtnetProvider.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import Foundation
import Network

class ArtnetProvider {
    static let port: UInt16 = 6454
    
    var sequence: UInt8 = 0
    
    var net: Int = 0
    var subnet: Int = 0
    var universe: Int = 0
    
    let _header: Data = {
        var packet = Data()
        
        packet.append("Art-Net".data(using: .ascii)!)
        packet.append(0x00)
        
//        # 8 - opcode (2 x 8 low byte first)
        packet.append(0x00)
        packet.append(0x50)  // ArtDmx data packet
//        # 10 - prototocol version (2 x 8 high byte first)
        packet.append(0x00)
        packet.append(14)
        
        return packet
    }()

    func packOne(payload: Data, offset: Int = 0) -> Data {
        var packet = Data(capacity: _header.count + 6 + payload.count)
        
        packet.append(_header)
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
        packet.append(contentsOf: payload.count.bytes[0...1].reversed())
        packet.append(payload)

        return packet
    }
    
    func pack(payload: Data) -> [Data] {
        let packets = payload.split(maxCount: 512).enumerated().map { self.packOne(payload: $1, offset: $0) }
        sequence = sequence.addingReportingOverflow(1).partialValue
        return packets
    }
    
    static func connection(host: String) -> NWConnection? {
        return NWConnection(host: .init(host), port: .init(integerLiteral: ArtnetProvider.port), using: .udp)
    }
    
    static func artpoll() -> Data {
        var packet = Data()
        
        packet.append("Art-Net".data(using: .ascii)!)
        packet.append(0x00)
        
//      opcode (2 x 8 low byte first)
        packet.append(0x00)
        packet.append(0x20)  // Artpoll packet
//      prototocol version (2 x 8 high byte first)
        packet.append(0x00)
        packet.append(14)
        // talktome
        packet.append(0x02)
        // priority
        packet.append(0x00)
        
        return packet
    }
        
    struct ArtpollReply {
        let host: String
        let port: Int
        
        let longname: String
    }
    
    static func readPacket(_ data: Data) -> Any? {
        let id = String(data: data[0 ..< 7], encoding: .utf8)
        
        guard id == "Art-Net" else {
            return nil
        }
        
        // Artpoll Reply
        if data[8] == 0x00 && data[9] == 0x21 {
            let ipData = data[10 ..< 14]
            let ip = ipData.map { String($0) }.joined(separator: ".")
            let port = Int(data: data[15...16])
            
//            let shortname = data[26..<44]
            guard let longname = String(data: data[44..<64], encoding: .utf8), longname.contains("LLED Fan") else {
                return nil
            }
            
            return ArtpollReply(host: ip, port: port, longname: longname)
        }
        
        return nil
    }
}
