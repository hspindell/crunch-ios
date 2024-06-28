//
//  BasicError.swift
//  Crunch
//
//  Created by Henry Spindell on 6/25/24.
//

import Foundation

public
struct BasicError: LocalizedError {
    public let errorDescription: String?
}

public extension String {
    /// Constructs MessageError with self as description
    var err: BasicError {
        BasicError(errorDescription: self)
    }
}
