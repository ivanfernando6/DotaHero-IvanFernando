//
//  HeroProvider.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import Moya

enum HeroProvider {
    case getAllHeroStat
}

extension HeroProvider: TargetType {
    var baseURL: URL {
        return URL(string: openDotaBaseUrl)!
    }
    
    var path: String {
        switch self {
        case .getAllHeroStat:
            return "/api/herostats"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllHeroStat:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getAllHeroStat:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAllHeroStat:
            return nil
        }
    }
    
}
