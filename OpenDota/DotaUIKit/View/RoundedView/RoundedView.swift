//
//  RoundedView.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit

class RoundedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width/2
    }
}
