//
//  ViewState.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import Foundation

enum ViewState {
    case loading
    case error(message: String)
    case ready
}
