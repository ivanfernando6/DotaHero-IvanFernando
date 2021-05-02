//
//  HeroListViewModel.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import RxSwift
import RxDataSources


class HeroListViewModel {
    struct Input {
        let didSelectModel: Observable<Int>
        let didFilterRole: Observable<Int>
        let didTapRetry: Observable<Void>
    }
    
    struct Output {
        let section: Observable<[HeroCollectionModel]>
        let role: Observable<[String]>
        let viewState: Observable<ViewState>
    }
    
    struct CoordinatorOutput {
        let didTapHero: Observable<Int?>
    }
    
    struct HeroSectionItemModel: IdentifiableType, Equatable {
        let id: Int
        let name: String
        let baseAttack: String
        let baseArmor: String
        let image: URL?
        let primaryAttribute: PrimaryAttribute?
        var identity: Int {
            return id
        }
        
        init(hero: HeroModel) {
            self.id = hero.id
            self.name = hero.localizedName ?? ""
            let baseAttackMin = Int(hero.baseAttackMin ?? 0)
            let baseAttackMax = Int(hero.baseAttackMax ??  0)
            self.baseAttack = "\(baseAttackMin)-\(baseAttackMax)"
            self.baseArmor = "\(Int(hero.baseArmor ?? 0))"
            self.image = hero.image
            self.primaryAttribute = hero.primaryAttribute
        }
        
        static func ==(lhs: HeroSectionItemModel, rhs: HeroSectionItemModel) -> Bool {
            return lhs.identity == rhs.identity
        }
    }
    
    struct HeroCollectionModel: AnimatableSectionModelType {
        let header: String
        var items: [HeroSectionItemModel]
        var identity: String {
            return header
        }
        
        init(header: String, items: [HeroSectionItemModel]) {
            self.header = header
            self.items = items
        }
        
        init(original: HeroCollectionModel, items: [HeroSectionItemModel]) {
            self.init(header: "Hero", items: items)
        }
    }
    struct RoleModel {
        let text: String
        let ids: Set<Int>
    }
    
    let disposeBag = DisposeBag()
    private let didTapHero = PublishSubject<Int?>()
    
    init() {
        
    }
    
    func tranform(input: Input) -> Output {
        let viewState = PublishSubject<ViewState>()
        let filteredHeroIds = BehaviorSubject<[Int]>(value: [])
        let rolesList = BehaviorSubject<[RoleModel]>(value: [])
        let shouldReloadHero = PublishSubject<Void>()
        
        let heroList = shouldReloadHero
            .startWith(())
            .do { _ in
                viewState.onNext(.loading)
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
            .flatMapLatest({ (_) -> Observable<[Int: HeroModel]> in
                return Datasource.shared.heroService.getAllHero()
                    .catchError { (error) -> Observable<[HeroModel]> in
                        let error = error as NSError
                        viewState.onNext(.error(message: error.localizedDescription))
                        return Observable.empty()
                    }
                    .map({ (models) -> [Int: HeroModel] in
                        var newModels: [Int: HeroModel] = [:]
                        models.forEach({ newModels[$0.id] = $0 })
                        return newModels
                    })
            })
            .do { (models) in
                var roles: [String: Set<Int>] = [:]
                models.values.forEach { (model) in
                    model.roles.forEach { (role) in
                        if roles[role] != nil {
                            roles[role]?.insert(model.id)
                        } else {
                            roles[role] = [model.id]
                        }
                    }
                }
                var roleModels = roles.map({ RoleModel(text: $0.key, ids: $0.value) })
                roleModels.prepend(RoleModel(text: "All", ids: []))
                rolesList.onNext(roleModels)
            }
            .do { _ in
                viewState.onNext(.ready)
            }
        
        let role = rolesList
            .map { (models) -> [String] in
                return models.map({ $0.text })
            }
        
        let section = Observable.combineLatest(heroList, filteredHeroIds)
            .map({ (heroes, filterHeroIds) -> [Int: HeroModel] in
                if filterHeroIds.count == 0 {
                    return heroes
                } else {
                    var filteredHero: [Int: HeroModel] = [:]
                    for id in filterHeroIds {
                        guard let model = heroes[id] else { continue }
                        filteredHero[id] = model
                    }
                    return filteredHero
                }
            })
            .map({ (models) -> [HeroModel] in
                return models.sorted(by: { $0.key < $1.key }).compactMap({ $0.value })
            })
            .map({ $0.map { (model) -> HeroSectionItemModel in
                return HeroSectionItemModel(hero: model)
            } })
            .map({ [HeroCollectionModel(header: "Hero", items: $0)] })
        
        input.didSelectModel
            .bind { [weak self] (id) in
                self?.didTapHero.onNext(id)
            }
            .disposed(by: disposeBag)
        
        input.didFilterRole
            .withLatestFrom(rolesList) { (filterIndex: $0, roles: $1) }
            .bind(onNext: { (index, roles) in
                if index == 0 {
                    filteredHeroIds.onNext([])
                } else if let ids = roles[safe: index]?.ids {
                    filteredHeroIds.onNext(Array(ids))
                }
            })
            .disposed(by: disposeBag)
        
        input.didTapRetry
            .bind(onNext: { (_) in
                shouldReloadHero.onNext(())
            })
            .disposed(by: disposeBag)
        
        
        return Output(
            section: section,
            role: role,
            viewState: viewState
        )
    }
    
    func coordinatorTransform() -> CoordinatorOutput {
        let didTapHero = self.didTapHero
        return CoordinatorOutput(
            didTapHero: didTapHero
        )
    }
    
}
