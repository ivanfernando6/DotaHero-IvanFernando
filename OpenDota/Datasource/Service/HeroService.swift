//
//  HeroService.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import RxSwift

protocol HeroServiceProtocol {
    func getAllHero() -> Observable<[HeroModel]>
    func getHero(id: Int) -> Observable<HeroModel?>
    func getOtherHero(id: Int, attribute: PrimaryAttribute, roles: [String], resultCount numberOfHero: Int) -> Observable<[HeroModel]>
}

class HeroService: HeroServiceProtocol {
    private let heroAccessor: HeroAccessorProtocol
    private let heroCache: HeroCacheProtocol?
    private let logger: LoggerProtocol?
    private let disposeBag = DisposeBag()
    private let syncHeroCache = PublishSubject<Void>()
    private let shouldUpdateHeroCache = PublishSubject<[HeroModel]>()
    
    init(heroAccessor: HeroAccessorProtocol, heroCache: HeroCacheProtocol?, logger: LoggerProtocol?) {
        self.heroAccessor = heroAccessor
        self.heroCache = heroCache
        self.logger = logger
        setupRx()
    }
    
    private func setupRx() {
        syncHeroCache.flatMap({ self.getAllHeroFromNetwork() })
            .subscribe { [weak self] (models) in
                self?.shouldUpdateHeroCache.onNext(models)
            } onError: { [weak self] (error) in
                self?.logger?.error(message: "sync hero failed while retrieve from network", error: error)
            }
            .disposed(by: disposeBag)
        
        shouldUpdateHeroCache
            .observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
            .bind { [weak self] (models) in
                self?.heroCache?.save(models)
            }
            .disposed(by: disposeBag)
    }
    
    func getHero(id: Int) -> Observable<HeroModel?> {
        return self.getHero(id: id, sync: false)
    }
    
    private func getHero(id: Int, sync: Bool) -> Observable<HeroModel?> {
        let cache = self.heroCache?.getHero(id: id) ?? Observable<HeroModel?>.just(nil)
        return cache
            .flatMap { [weak self] (model) -> Observable<HeroModel?> in
                guard let self = self else { return Observable.empty() }
                if let model = model {
                    return Observable.just(model)
                } else {
                    return self.getAllHero(sync: sync)
                        .map({ (models) -> HeroModel? in
                            return models.first(where: { $0.id == id })
                        })
                }
            }
    }
    
    func getOtherHero(id: Int, attribute: PrimaryAttribute, roles: [String], resultCount numberOfHero: Int) -> Observable<[HeroModel]> {
//        If selected hero attribute is “agi”, show 3 heroes with highest movement speed
//        If selected hero attribute is “str”, show 3 heroes with highest base attack max
//        If selected hero attribute is “int”, show 3 heroes with highest base mana
        let roleSet = Set(roles)
        return self.getAllHero(sync: false)
            .map({ (models) -> [HeroModel] in
                return models.filter({ $0.primaryAttribute == attribute })
                    .filter { (model) -> Bool in
                        let modelRoleSet = Set(model.roles)
                        return modelRoleSet.intersection(roleSet).count > 0
                    }
                    .filter({ $0.id != id })
            })
            .map({ (models) -> [HeroModel] in
                var result: [HeroModel] = []
                switch attribute {
                case .agility:
                    result = models.sorted(by: { $0.moveSpeed ?? 0 > $1.moveSpeed ?? 0 })
                case .strength:
                    result = models.sorted(by: { $0.baseAttackMax ?? 0 > $1.baseAttackMax ?? 0 })
                case .inteligence:
                    result = models.sorted(by: { $0.baseMana ?? 0 > $1.baseMana ?? 0 })
                }
                return result
            })
            .map({ Array($0.prefix(numberOfHero)) })
    }
    
    func getAllHero() -> Observable<[HeroModel]> {
        return self.getAllHero(sync: true)
    }
    
    private func getAllHero(sync syncLocal: Bool) -> Observable<[HeroModel]> {
        let cache = self.heroCache?.getAllHeroStat() ?? Observable<[HeroModel]>.just([])
        return cache
            .map({ (models) -> [HeroModel] in
                return models.sorted(by: { $0.id < $1.id })
            })
            .flatMap { [weak self] (cacheHero) -> Observable<[HeroModel]> in
                guard let self = self else { return Observable.just([]) }
                if cacheHero.count > 0 {
                    self.logger?.info(message: "Get Hero cache from cache")
                    return Observable.just(cacheHero)
                        .do { _ in
                            if syncLocal {
                                self.syncHeroCache.onNext(())
                            }
                        }
                } else {
                    self.logger?.info(message: "Get Hero cache from network")
                    return
                        self.getAllHeroFromNetwork()
                        .do { (models) in
                            self.shouldUpdateHeroCache.onNext(models)
                        }
                }
            }
    }
    
    private func getAllHeroFromNetwork() -> Observable<[HeroModel]> {
        return self.heroAccessor.getAllHeroStat()
            .map { (models) -> [HeroModel] in
                return models.sorted(by: { $0.id < $1.id })
            }
    }
}
