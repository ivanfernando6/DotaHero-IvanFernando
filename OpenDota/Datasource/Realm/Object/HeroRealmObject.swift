//
//  HeroRealmObject.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import RealmSwift

class HeroRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var localizedName: String = ""
    @objc dynamic var primaryAttribute: String = ""
    @objc dynamic var attackType: String = ""
    var roles = List<String>()
    @objc dynamic var image: String = ""
    var baseHealth = RealmOptional<Double>()
    var baseMana = RealmOptional<Double>()
    var baseArmor = RealmOptional<Double>()
    var baseAttackMin = RealmOptional<Double>()
    var baseAttackMax = RealmOptional<Double>()
    var moveSpeed = RealmOptional<Double>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(hero: HeroModel) {
        self.init()
        self.id = hero.id
        self.localizedName = hero.localizedName ?? ""
        self.primaryAttribute = hero.primaryAttribute?.rawValue ?? ""
        self.attackType = hero.attackType?.rawValue ?? ""
        let roles = List<String>()
        hero.roles.forEach({ roles.append($0) })
        self.roles = roles
        self.image = hero.image?.absoluteString ?? ""
        self.baseHealth = RealmOptional(hero.baseHealth)
        self.baseMana = RealmOptional(hero.baseMana)
        self.baseArmor = RealmOptional(hero.baseArmor)
        self.baseAttackMin = RealmOptional(hero.baseAttackMin)
        self.baseAttackMax = RealmOptional(hero.baseAttackMax)
        self.moveSpeed = RealmOptional(hero.moveSpeed)
    }
    
    func toModel() -> HeroModel? {
        return HeroModel(id: self.id,
                         localizedName: self.localizedName,
                         primaryAttribute: PrimaryAttribute.get(identifier: self.primaryAttribute),
                         attackType: AttackType.get(identifier: self.attackType),
                         roles: self.roles.map({ $0 }),
                         image: self.image.toURL(),
                         baseHealth: self.baseHealth.value,
                         baseMana: self.baseMana.value,
                         baseArmor: self.baseArmor.value,
                         baseAttackMin: self.baseAttackMin.value,
                         baseAttackMax: self.baseAttackMax.value,
                         moveSpeed: self.moveSpeed.value)
    }
}
