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

struct Profile: Codable, Equatable, Identifiable {
    var id: UUID
    var username: String
}

extension Profile {
    static let sample = Profile(id: UUID(), username: "previewuser")
}
