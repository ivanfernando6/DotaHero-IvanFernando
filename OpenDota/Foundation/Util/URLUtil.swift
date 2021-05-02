//
//  URLUtil.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation

class URLUtil {
    static func toOpenDotaURL(from urlString: String?) -> URL? {
        guard let urlString = urlString else { return nil }
        return "\(openDotaBaseUrl)\(urlString)".toURL()
    }
}
