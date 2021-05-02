//
//  HeroModel.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation

struct HeroModel: Codable {
    let id: Int
    let localizedName: String?
    let primaryAttribute: PrimaryAttribute?
    let attackType: AttackType?
    let roles: [String]
    let image: URL?
    let baseHealth: Double?
    let baseMana: Double?
    let baseArmor: Double?
    let baseAttackMin: Double?
    let baseAttackMax: Double?
    let moveSpeed: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id, roles
        case localizedName = "localized_name"
        case primaryAttribute = "primary_attr"
        case attackType = "attack_type"
        case image = "img"
        case baseHealth = "base_health"
        case baseMana = "base_mana"
        case baseArmor = "base_armor"
        case baseAttackMin = "base_attack_min"
        case baseAttackMax = "base_attack_max"
        case moveSpeed = "move_speed"
    }
    
    init(from decoder: Decoder) throws {
        let object = try decoder.container(keyedBy: CodingKeys.self)
        id = try object.decode(Int.self, forKey: .id)
        localizedName = try object.decodeIfPresent(String.self, forKey: .localizedName)
        primaryAttribute = try object.decodeIfPresent(PrimaryAttribute.self, forKey: .primaryAttribute)
        attackType = try object.decodeIfPresent(AttackType.self, forKey: .attackType)
        roles = try object.decodeIfPresent([String].self, forKey: .roles) ?? []
        let image = try object.decodeIfPresent(String.self, forKey: .image)
        self.image = URLUtil.toOpenDotaURL(from: image)
        baseHealth = try object.decodeIfPresent(Double.self, forKey: .baseHealth)
        baseMana = try object.decodeIfPresent(Double.self, forKey: .baseMana)
        baseArmor = try object.decodeIfPresent(Double.self, forKey: .baseArmor)
        baseAttackMin = try object.decodeIfPresent(Double.self, forKey: .baseAttackMin)
        baseAttackMax = try object.decodeIfPresent(Double.self, forKey: .baseAttackMax)
        moveSpeed = try object.decodeIfPresent(Double.self, forKey: .moveSpeed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(localizedName, forKey: .localizedName)
        try container.encode(primaryAttribute?.rawValue, forKey: .primaryAttribute)
        try container.encode(attackType, forKey: .attackType)
        try container.encode(roles, forKey: .roles)
        try container.encode(image, forKey: .image)
        try container.encode(baseHealth, forKey: .baseHealth)
        try container.encode(baseMana, forKey: .baseMana)
        try container.encode(baseArmor, forKey: .baseArmor)
        try container.encode(baseAttackMin, forKey: .baseAttackMin)
        try container.encode(baseAttackMax, forKey: .baseAttackMax)
        try container.encode(moveSpeed, forKey: .moveSpeed)
    }
    
    init(id: Int, localizedName: String?, primaryAttribute: PrimaryAttribute?, attackType: AttackType?, roles: [String], image: URL?, baseHealth: Double?, baseMana: Double?, baseArmor: Double?, baseAttackMin: Double?, baseAttackMax: Double?, moveSpeed: Double?) {
        self.id = id
        self.localizedName = localizedName
        self.primaryAttribute = primaryAttribute
        self.attackType = attackType
        self.roles = roles
        self.image = image
        self.baseHealth = baseHealth
        self.baseMana = baseMana
        self.baseArmor = baseArmor
        self.baseAttackMin = baseAttackMin
        self.baseAttackMax = baseAttackMax
        self.moveSpeed = moveSpeed
    }
    
}
