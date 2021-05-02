//
//  BaseViewController.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit
import KRProgressHUD

class BaseViewController: UIViewController {
    let uuid = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("\(self.className()) \(uuid) is deinit")
    }
    
    func showLoading(message: String = "Loading...") {
        KRProgressHUD
            .showOn(self)
            .show(withMessage: message, completion: nil)
    }
    
    func dismissLoading() {
        KRProgressHUD.dismiss()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

