//
//  AttackType.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import Foundation

enum AttackType: String, Codable {
    case melee = "Melee"
    case ranged = "Ranged"
    
    static func get(identifier: String) -> AttackType? {
        return AttackType(rawValue: identifier)
    }
}
