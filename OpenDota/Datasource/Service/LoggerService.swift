//
//  LoggerService.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation

protocol LoggerProtocol {
    func info(message: String)
    func error(message: String, error: Error?)
}

class LoggerService: LoggerProtocol {
    init() {}
    
    func info(message: String) {
        print(message)
    }
    
    func error(message: String, error: Error?) {
        print(message)
        if let error = error {
            print(error)
        }
    }
}
