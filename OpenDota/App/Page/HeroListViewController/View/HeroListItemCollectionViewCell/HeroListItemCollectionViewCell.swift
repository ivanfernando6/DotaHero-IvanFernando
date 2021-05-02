//
//  HeroListItemCollectionViewCell.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit
import Kingfisher

class HeroListItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var heroImageView: UIImageView!
    @IBOutlet private var heroNameLabel: UILabel!
    @IBOutlet private var baseAttackMediaLabel: MediaLabel!
    @IBOutlet private var baseArmorMediaLabel: MediaLabel!
    @IBOutlet private var heroAttributeColorView: UIView!
    @IBOutlet private var textContainerView: UIView!
    
    static let nib = UINib(nibName: HeroListItemCollectionViewCell.className(), bundle: Bundle(for: HeroListItemCollectionViewCell.self))
    static let identifier = HeroListItemCollectionViewCell.className()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(name: String, baseAttack: String, baseArmor: String, image: URL?, primaryAttribute: PrimaryAttribute?) {
        self.heroNameLabel.text = name
        self.baseAttackMediaLabel.configure(for: .attack, text: baseAttack)
        self.baseArmorMediaLabel.configure(for: .armor, text: baseArmor)
        self.heroImageView.kf.setImage(with: image, placeholder: #imageLiteral(resourceName: "attributePlaceholder"))
        self.heroAttributeColorView.backgroundColor = primaryAttribute?.representativeColor
    }

}
