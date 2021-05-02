//
//  HeroDetailViewController.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import UIKit
import RxSwift
import RxCocoa

class HeroDetailViewController: BaseViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var otherHeroStackView: UIStackView!
    @IBOutlet private var heroInfoView: HeroDetailInfoView!
    @IBOutlet private var generalErrorView: GeneralErrorView!
    
    var viewModel: HeroDetailViewModel?
    private let disposeBag = DisposeBag()
    private let didTapOtherHero = PublishSubject<Int?>()
    private let didTapRetry = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        setupRx()
    }
    
    private func setupView() {
        scrollView.indicatorStyle = .black
        generalErrorView.showButton = true
        generalErrorView.output = self
    }
    
    private func setupRx() {
        guard let viewModel = viewModel else { return }
        let input = HeroDetailViewModel.Input(
            didTapOtherHero: didTapOtherHero,
            didTapRetry: didTapRetry
        )
        let output = viewModel.transform(input: input)
        
        output.viewState.asDriver(onErrorJustReturn: .ready)
            .drive { [weak self] (state) in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.showLoading()
                case .error(let message):
                    self.generalErrorView.isHidden = false
                    self.dismissLoading()
                    self.showError(message: message)
                case .ready:
                    self.generalErrorView.isHidden = true
                    self.dismissLoading()
                }
            }
            .disposed(by: disposeBag)
        
        output.heroDetail.asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive { [weak self] (model) in
                self?.heroInfoView.configure(name: model.heroName, attackType: model.attackType, primaryAttribute: model.primaryAttribute, baseHealth: model.baseHealth, baseAttackMax: model.baseAttackMax, moveSpeed: model.moveSpeed, roles: model.roles, image: model.image)
            }
            .disposed(by: disposeBag)
        
        output.otherHero.asDriver(onErrorJustReturn: [])
            .map({ [weak self] (models) -> [OtherHeroView] in
                return models.map { (model) -> OtherHeroView in
                    let view = OtherHeroView()
                    view.output = self
                    view.configure(id: model.id, name: model.heroName, image: model.image)
                    return view
                }
            })
            .drive { [weak self] (views) in
                guard let self = self else { return }
                self.otherHeroStackView.addArrangedSubviews(views)
                self.otherHeroStackView.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }
}

extension HeroDetailViewController: OtherHeroViewOutput {
    func didTapOtherHero(id: Int?) {
        self.didTapOtherHero.onNext(id)
    }
}

extension HeroDetailViewController: GeneralErrorViewOutput {
    func didTapActionButton() {
        didTapRetry.onNext(())
    }
}
