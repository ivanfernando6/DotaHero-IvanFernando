//
//  HeroDetailViewModel.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/21.
//

import Foundation
import RxSwift


class HeroDetailViewModel {
    struct Input {
        let didTapOtherHero: Observable<Int?>
        let didTapRetry: Observable<Void>
    }
    
    struct Output {
        let heroDetail: Observable<HeroDetail?>
        let otherHero: Observable<[OtherHeroInfo]>
        let viewState: Observable<ViewState>
    }
    
    struct CoordinatorOutput {
        let didTapOtherHero: Observable<Int?>
    }
    
    struct HeroDetail {
        let heroName: String
        let attackType: AttackType?
        let primaryAttribute: PrimaryAttribute?
        let baseHealth: String
        let baseAttackMax: String
        let moveSpeed: String
        let roles: [String]
        let image: URL?
        
        init?(from model: HeroModel?) {
            guard let model = model else { return nil }
            self.init(heroName: model.localizedName ?? "",
                      attackType: model.attackType,
                      primaryAttribute: model.primaryAttribute,
                      baseHealth: "\(Int(model.baseHealth ?? 0))",
                      baseAttackMax: "\(Int(model.baseAttackMax ?? 0))",
                      moveSpeed: "\(Int(model.moveSpeed ?? 0))",
                      roles: model.roles,
                      image: model.image)
        }
        
        init(heroName: String, attackType: AttackType?, primaryAttribute: PrimaryAttribute?, baseHealth: String, baseAttackMax: String, moveSpeed: String, roles: [String], image: URL?) {
            self.heroName = heroName
            self.attackType = attackType
            self.primaryAttribute = primaryAttribute
            self.baseHealth = baseHealth
            self.baseAttackMax = baseAttackMax
            self.moveSpeed = moveSpeed
            self.roles = roles
            self.image = image
        }

    }
    
    struct OtherHeroInfo {
        let id: Int
        let heroName: String
        let image: URL?
        
        init(from model: HeroModel) {
            self.id = model.id
            self.heroName = model.localizedName ?? ""
            self.image = model.image
        }
    }
    
    private let heroId: Int
    let disposeBag = DisposeBag()
    private let didTapOtherHero = PublishSubject<Int?>()
    
    init(id: Int) {
        self.heroId = id
    }
    
    func transform(input: Input) -> Output {
        let viewState = PublishSubject<ViewState>()
        let shouldReloadData = PublishSubject<Void>()
        let heroModel = BehaviorSubject<HeroModel?>(value: nil)
        
        let otherHeroModel = shouldReloadData
            .startWith(())
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
            .do { _ in
                viewState.onNext(.loading)
            }
            .flatMapLatest({ [weak self] (_) -> Observable<HeroModel> in
                guard let self = self else { return Observable.empty() }
                return Datasource.shared.heroService.getHero(id: self.heroId)
                    .catchErrorJustReturn(nil)
                    .do { model in
                        if model == nil {
                            viewState.onNext(.error(message: "Something went wrong. Please try again in few minutes"))
                        }
                    }
                    .compactMap({ $0 })
            })
            .do { model in
                heroModel.onNext(model)
            }
            .filter({ $0.primaryAttribute != nil })
            .map({ (id: $0.id, primaryAttribute: $0.primaryAttribute!, roles: $0.roles) })
            .flatMapLatest({ (id, primaryAttribute, roles) -> Observable<[HeroModel]> in
                return Datasource.shared.heroService.getOtherHero(id: id, attribute: primaryAttribute, roles: roles, resultCount: 3)
                    .catchError { (error) -> Observable<[HeroModel]> in
                        let error = error as NSError
                        viewState.onNext(.error(message: error.localizedDescription))
                        return Observable.empty()
                    }
            })
            .do { _ in
                viewState.onNext(.ready)
            }
            
        let heroDetail = heroModel
            .map({ HeroDetail(from: $0) })
            .startWith(HeroDetail(heroName: "",
                                  attackType: nil,
                                  primaryAttribute: nil,
                                  baseHealth: "0",
                                  baseAttackMax: "0",
                                  moveSpeed: "0",
                                  roles: [],
                                  image: nil))
        
        let otherHero = otherHeroModel
            .map { (models) -> [OtherHeroInfo] in
                return models.map({ OtherHeroInfo(from: $0) })
            }
        
        input.didTapOtherHero
            .bind { [weak self] (id) in
                self?.didTapOtherHero.onNext(id)
            }
            .disposed(by: disposeBag)
        
        input.didTapRetry
            .bind { (_) in
                shouldReloadData.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(
            heroDetail: heroDetail,
            otherHero: otherHero,
            viewState: viewState
        )
    }
    
    func coordinatorTransform() -> CoordinatorOutput {
        let didTapOtherHero = self.didTapOtherHero
        return CoordinatorOutput(
            didTapOtherHero: didTapOtherHero
        )
    }
}
