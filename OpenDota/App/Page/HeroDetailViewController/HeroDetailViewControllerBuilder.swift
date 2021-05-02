//
//  HeroDetailViewControllerBuilder.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import UIKit

class HeroDetailViewControllerBuilder {
    private(set) var navigationController: UINavigationController?
    private(set) var viewController: UIViewController?
    private(set) var viewModel: HeroDetailViewModel?
    
    func build(id: Int) -> HeroDetailViewControllerBuilder {
        let storyboard = UIStoryboard(name: "HeroDetailViewController", bundle: Bundle(for: HeroDetailViewController.self))
        guard let navController = storyboard.instantiateViewController(identifier: "HeroDetailViewController") as? UINavigationController,
              let controller = navController.viewControllers.first as? HeroDetailViewController else {
            return self
        }
        let viewModel = HeroDetailViewModel(id: id)
        controller.viewModel = viewModel
        self.navigationController = navController
        self.viewController = controller
        self.viewModel = viewModel
        return self
    }
}
