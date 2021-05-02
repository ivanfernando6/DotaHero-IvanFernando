//
//  AppCoordinator.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import UIKit
import RxSwift

enum AppViewController {
    case hero
}

class AppCoordinator {
    private(set) var navigationController: UINavigationController?
    private let bundle = Bundle(for: AppCoordinator.self)
    
    required init(rootController: AppViewController) {
        navigationController = self.build(rootController: rootController)
    }
    
    private func build(rootController: AppViewController) -> UINavigationController? {
        switch rootController {
        case .hero:
            let builder = HeroListViewControllerBuilder().build()
            if let viewModel = builder.viewModel {
                let output = viewModel.coordinatorTransform()
                self.setupHeroListCoordinatorOutput(output: output, disposeBag: viewModel.disposeBag)
            }
            return builder.navigationController
        }
    }
    
    private func setupHeroListCoordinatorOutput(output: HeroListViewModel.CoordinatorOutput, disposeBag: DisposeBag?) {
        guard let disposeBag = disposeBag else { return }
        output.didTapHero
            .bind { [weak self] (id) in
                guard let id = id else { return }
                self?.showHeroDetail(id: id)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupHeroDetailOutput(output: HeroDetailViewModel.CoordinatorOutput, disposeBag: DisposeBag?){
        guard let disposeBag = disposeBag else { return }
        output.didTapOtherHero
            .bind { [weak self] (id) in
                guard let id = id else { return }
                self?.showHeroDetail(id: id)
            }
            .disposed(by: disposeBag)
    }
    
    private func showHeroDetail(id: Int) {
        let builder = HeroDetailViewControllerBuilder().build(id: id)
        if let heroDetailViewController = builder.viewController as? HeroDetailViewController,
           let viewModel = builder.viewModel {
            let output = viewModel.coordinatorTransform()
            self.setupHeroDetailOutput(output: output, disposeBag: viewModel.disposeBag)
            self.navigationController?.pushViewController(heroDetailViewController, animated: true)
        }
    }
}
