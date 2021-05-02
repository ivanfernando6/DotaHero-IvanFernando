//
//  HeroListViewController.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PinterestSegment

class HeroListViewController: BaseViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewFlowLayout: HeroListViewFlowLayout!
    @IBOutlet private var segmentControlView: PinterestSegment!
    @IBOutlet private var errorView: GeneralErrorView!
    
    var viewModel: HeroListViewModel?
    private let disposeBag = DisposeBag()
    private let didSelectModel = PublishSubject<Int>()
    private let didFilterRole = PublishSubject<Int>()
    private let didTapRetry = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setupCollectionView()
        setupRx()
    }
    
    private func setupView() {
        var style = PinterestSegmentStyle()
        style.titleFont = UIFont.boldSystemFont(ofSize: 14)
        style.normalTitleColor = UIColor.desertStorm ?? UIColor.lightGray
        style.selectedTitleColor = UIColor.riverBed ?? UIColor.darkGray
        style.indicatorColor = UIColor.desertStorm ?? UIColor.white
        segmentControlView.style = style
        errorView.output = self
        errorView.showButton = true
    }
    
    private func setupCollectionView() {
        collectionView.register(HeroListItemCollectionViewCell.nib, forCellWithReuseIdentifier: HeroListItemCollectionViewCell.identifier)
        collectionView.indicatorStyle = .black
    }
    
    private func setupRx() {
        guard let viewModel = viewModel else { return }
        let input = HeroListViewModel.Input(
            didSelectModel: didSelectModel,
            didFilterRole: didFilterRole,
            didTapRetry: didTapRetry
        )
        let output = viewModel.tranform(input: input)
        let datasource = RxCollectionViewSectionedAnimatedDataSource<HeroListViewModel.HeroCollectionModel> { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroListItemCollectionViewCell.identifier, for: indexPath) as? HeroListItemCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(name: item.name, baseAttack: item.baseAttack, baseArmor: item.baseArmor, image: item.image, primaryAttribute: item.primaryAttribute)
            return cell
        }
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.collectionView.deselectItem(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(HeroListViewModel.HeroSectionItemModel.self)
            .bind { [weak self] (model) in
                self?.didSelectModel.onNext(model.identity)
            }
            .disposed(by: disposeBag)
        
        segmentControlView.rx.controlEvent(.valueChanged)
            .map({ [weak self] in self?.segmentControlView.selectIndex })
            .compactMap({ $0 })
            .do { [weak self] (_) in
                self?.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            .bind { [weak self] (index) in
                self?.didFilterRole.onNext(index)
            }
            .disposed(by: disposeBag)
        
        output.viewState.asDriver(onErrorJustReturn: .ready)
            .drive { [weak self ](state) in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.showLoading()
                case .error(let message):
                    self.errorView.isHidden = false
                    self.dismissLoading()
                    self.showError(message: message)
                case .ready:
                    self.errorView.isHidden = true
                    self.dismissLoading()
                }
            }
            .disposed(by: disposeBag)

        output.section.asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        output.role.asDriver(onErrorJustReturn: [])
            .map({ $0.map { (role) -> PinterestSegment.TitleElement in
                return PinterestSegment.TitleElement(title: role)
            } })
            .drive { [weak self] (roles) in
                self?.segmentControlView.setRichTextTitles(roles)
            }
            .disposed(by: disposeBag)
    }

}

extension HeroListViewController: UICollectionViewDelegate {
    
}

extension HeroListViewController: GeneralErrorViewOutput {
    func didTapActionButton() {
        didTapRetry.onNext(())
    }
}
