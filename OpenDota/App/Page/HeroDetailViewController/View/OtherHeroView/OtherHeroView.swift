//
//  OtherHeroView.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit
import Kingfisher

protocol OtherHeroViewOutput: AnyObject {
    func didTapOtherHero(id: Int?)
}

class OtherHeroView: BaseView {

    @IBOutlet private var heroImageContainerView: UIView!
    @IBOutlet private var heroImageView: UIImageView!
    @IBOutlet private var heroNameLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    
    weak var output: OtherHeroViewOutput?
    private var id: Int?
    
    func configure(id: Int, name: String, image: URL?) {
        self.id = id
        self.heroNameLabel.text = name
        self.heroImageView.kf.setImage(with: image, placeholder: UIImage(named: "heroPlaceholder"))
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        self.output?.didTapOtherHero(id: id)
    }
}
