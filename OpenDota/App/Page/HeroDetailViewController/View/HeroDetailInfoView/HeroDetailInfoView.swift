//
//  HeroDetailInfoView.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import UIKit

class HeroDetailInfoView: BaseView {

    @IBOutlet private var heroImageView: UIImageView!
    @IBOutlet private var attackTypeImageView: UIImageView!
    @IBOutlet private var primaryAttributeImageView: UIImageView!
    @IBOutlet private var heroNameLabel: UILabel!
    @IBOutlet private var healthLabel: MediaLabel!
    @IBOutlet private var maxAttackLabel: MediaLabel!
    @IBOutlet private var movementSpeedLabel: MediaLabel!
    @IBOutlet private var roleItemLabel: UILabel!
    
    func configure(name: String, attackType: AttackType?, primaryAttribute: PrimaryAttribute?, baseHealth: String, baseAttackMax: String, moveSpeed: String, roles: [String], image: URL?) {
        self.heroNameLabel.text = name
        self.setAttackTypeImage(by: attackType)
        self.setPrimaryAttributeImage(by: primaryAttribute)
        self.healthLabel.configure(for: .health, text: baseHealth)
        self.maxAttackLabel.configure(for: .attack, text: baseAttackMax)
        self.movementSpeedLabel.configure(for: .moveSpeed, text: moveSpeed)
        self.roleItemLabel.text = roles.joined(separator: ", ")
        self.heroImageView.kf.setImage(with: image, placeholder: #imageLiteral(resourceName: "attributePlaceholder"))
    }
    
    private func setAttackTypeImage(by attackType: AttackType?) {
        guard let attackType = attackType else { return }
        switch attackType {
        case .melee:
            attackTypeImageView.image = #imageLiteral(resourceName: "melee")
        case .ranged:
            attackTypeImageView.image = #imageLiteral(resourceName: "ranged")
        }
    }
    
    private func setPrimaryAttributeImage(by primaryAttribute: PrimaryAttribute?) {
        guard let primaryAttribute = primaryAttribute else { return }
        switch primaryAttribute {
        case .agility:
            primaryAttributeImageView.image = #imageLiteral(resourceName: "agility")
        case .strength:
            primaryAttributeImageView.image = #imageLiteral(resourceName: "strength")
        case .inteligence:
            primaryAttributeImageView.image = #imageLiteral(resourceName: "intelligence")
        }
    }

}
