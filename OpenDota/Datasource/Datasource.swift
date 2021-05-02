//
//  Datasource.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation

class Datasource {
    static let shared = Datasource()
    private var _heroService: HeroServiceProtocol?
    var heroService: HeroServiceProtocol {
        if self._heroService == nil {
            self._heroService = HeroService(heroAccessor: self.heroAccessor, heroCache: self.heroCache, logger: self.logger)
        }
        return self._heroService!
    }
    private var realmService: RealmServiceProtocol?
    private var heroCache: HeroCacheProtocol?
    private lazy var heroAccessor: HeroAccessorProtocol = HeroAccessor()
    private lazy var logger: LoggerProtocol = LoggerService()
    
    private init() {
        let realmService = RealmService(logger: self.logger)
        self.realmService = realmService
        self.heroCache = HeroCache(realm: realmService, logger: self.logger)
    }
    
    func warmUp() {
        self.logger.info(message: "Datasource Warmup")
    }
}
