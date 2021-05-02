//
//  PrimaryAttribute.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import UIKit

enum PrimaryAttribute: String, Decodable {
    case strength = "str"
    case agility = "agi"
    case inteligence = "int"
    
    static func get(identifier: String) -> PrimaryAttribute? {
        return PrimaryAttribute(rawValue: identifier.lowercased())
    }
    
    var representativeColor: UIColor {
        switch self {
        case .strength:
            return UIColor.red
        case .agility:
            return UIColor.green
        case .inteligence:
            return UIColor.blue
        }
    }
}
