//
//  RxExtension.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation
import RxSwift
import Moya

extension ObservableType where Element == Response {
    func filterResponse() -> Observable<Element> {
        return flatMap { (element) -> Observable<Element> in
            let statusCode = element.statusCode
            if (200...299).contains(statusCode) {
                return .just(element)
            }
            var localizedString: String
            switch statusCode {
            case 404:
                localizedString = NSLocalizedString("ERROR_NOT_FOUND", comment: "Resource not found")
            case 400:
                localizedString = NSLocalizedString("ERROR_BAD_REQUEST", comment: "Bad request")
            case NSURLErrorNetworkConnectionLost:
                localizedString = NSLocalizedString("ERROR_NETWORK_CONNECTION_LOST", comment: "Connection lost.")
            case NSURLErrorTimedOut:
                localizedString = NSLocalizedString("ERROR_REQUEST_TIMEDOUT", comment: "Server Timedout")
            default:
                localizedString = NSLocalizedString("ERROR_SERVER_ERROR", comment: "Server Error")
            }
            let error = NSError(domain: ErrorDomain.datasource.rawValue,
                                code: statusCode,
                                userInfo: [NSLocalizedDescriptionKey: localizedString])
            return Observable.error(error)
        }
    }

}
