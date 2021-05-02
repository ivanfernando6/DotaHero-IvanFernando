//
//  BaseView.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubview()
    }
    
    open func loadView() {
        
    }
    
    private func setupSubview() {
        let bundle: Bundle = Bundle(for: type(of: self))
        let view: UIView = bundle.loadNibNamed(self.className(), owner: self, options: nil)?.first as! UIView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.backgroundColor
        self.insertSubview(view, at: 0)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["view": view]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["view": view]))
        self.loadView()
    }
}
