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
    static let sample = Profile(id: UUID(uuidString: "ABCC5472-7A84-4ABC-9CA8-6CDFB34D5CE8")!, username: "hspindell")
}

extension AppObject {
    static let sample = AppObject(userProfile: Profile.sample)
}
