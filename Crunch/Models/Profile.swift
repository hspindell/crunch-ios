//
//  Profile.swift
//  Crunch
//
//  Created by Henry Spindell on 5/16/24.
//

import Foundation

struct ProfileCreation {
    var username: String
}

struct Profile: Codable, Equatable {
    var id: UUID
    var username: String
}
