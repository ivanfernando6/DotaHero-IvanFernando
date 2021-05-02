//
//  RealmService.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import RealmSwift

protocol RealmServiceProtocol {
    var instance: Realm? { get }
}

class RealmService: RealmServiceProtocol {
    var instance: Realm? {
        do {
            return try Realm(configuration: config)
        } catch let error {
            self.logger?.error(message: "Error init Realm", error: error)
            return nil
        }
    }
    private let config: Realm.Configuration
    private let logger: LoggerProtocol?

    required init(logger: LoggerProtocol?) {
        self.logger = logger
        let schemaVersion: UInt64 = 0
        self.config = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
            
        })
        Realm.Configuration.defaultConfiguration = self.config
        do {
            _ = try Realm(configuration: self.config)
        } catch let error {
            self.logger?.error(message: "Error init realm for migration", error: error)
        }
    }
}
