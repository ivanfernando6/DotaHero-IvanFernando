//
//  GeneralErrorView.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit

protocol GeneralErrorViewOutput: AnyObject {
    func didTapActionButton()
}

class GeneralErrorView: BaseView {
    
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var buttonContainerView: UIView!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var buttonContainerZeroHeightConstraint: NSLayoutConstraint!
    
    weak var output: GeneralErrorViewOutput?
    
    var showButton: Bool = false {
        didSet {
            buttonContainerZeroHeightConstraint.isActive = !showButton
        }
    }
    var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    var actionButtonTitle: String? {
        didSet {
            actionButton.setTitle(actionButtonTitle, for: .normal)
        }
    }
    
    @IBAction private func didTapActionButton(_ sender: UIButton) {
        output?.didTapActionButton()
    }
}
