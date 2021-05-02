//
//  HeroCache.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import RealmSwift
import RxSwift

protocol HeroCacheProtocol: HeroAccessorProtocol {
    func save(_ values: [HeroModel])
    func getHero(id: Int) -> Observable<HeroModel?>
}

class HeroCache: HeroCacheProtocol {
    let realmService: RealmServiceProtocol
    let logger: LoggerProtocol?
    
    init(realm: RealmServiceProtocol, logger: LoggerProtocol?) {
        self.realmService = realm
        self.logger = logger
    }
    
    func getHero(id: Int) -> Observable<HeroModel?> {
        guard let realmInstance = self.realmService.instance,
              let result = realmInstance.object(ofType: HeroRealmObject.self, forPrimaryKey: id)?.toModel()
        else { return Observable.just(nil) }
        
        return Observable.just(result)
    }
    
    func getAllHeroStat() -> Observable<[HeroModel]> {
        guard let realmInstance = self.realmService.instance else { return Observable.just([]) }
        let heroObjects = Array(realmInstance.objects(HeroRealmObject.self))
        let result = heroObjects.compactMap({ $0.toModel() })
        return Observable.just(result)
    }
    
    func save(_ values: [HeroModel]) {
        self.logger?.info(message: "save hero cache started")
        guard let realmInstance = self.realmService.instance else {
            self.logger?.error(message: "save hero cache failed", error: nil)
            return
        }
        do {
            realmInstance.beginWrite()
            values.forEach { (value) in
                let object = HeroRealmObject(hero: value)
                realmInstance.add(object, update: .modified)
            }
            try realmInstance.commitWrite()
            self.logger?.info(message: "save hero cache completed")
        } catch let error {
            self.logger?.error(message: "save hero cache failed", error: error)
        }
    }
}
