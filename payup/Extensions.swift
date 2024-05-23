//
//  Extensions.swift
//  payup
//
//  Created by Henry Spindell on 5/16/24.
//

import Foundation

extension Optional {
    var isNil: Bool {
        self == nil
    }
    
    var hasValue: Bool {
        self != nil
    }
}

extension String {
    var url: URL? {
        return URL(string: self)
    }
}
