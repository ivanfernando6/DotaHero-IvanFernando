//
//  MediaLabel.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import UIKit

class MediaLabel: BaseView {
    
    @IBOutlet private var wrapperView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    
    func configure(for attribute: MediaLabelHeroAttribute, text: String?) {
        self.textLabel.text = text
        switch attribute {
        case .attack:
            self.imageView.image = #imageLiteral(resourceName: "attack")
        case .armor:
            self.imageView.image = #imageLiteral(resourceName: "defend")
        case .health:
            self.imageView.image = #imageLiteral(resourceName: "health")
        case .meleeAttack:
            self.imageView.image = #imageLiteral(resourceName: "melee")
        case .rangedAttack:
            self.imageView.image = #imageLiteral(resourceName: "ranged")
        case .moveSpeed:
            self.imageView.image = #imageLiteral(resourceName: "moveSpeed")
        }
    }
    
    func configure(imageURL: URL?, text: String?) {
        self.imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "heroPlaceholder"))
    }
}
