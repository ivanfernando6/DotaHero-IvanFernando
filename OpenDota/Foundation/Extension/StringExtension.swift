//
//  StringExtension.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation

extension String {
    func toURL() -> URL? {
        return URL(string: self)
    }
}
