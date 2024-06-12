//
//  Circle.swift
//  Crunch
//
//  Created by Henry Spindell on 5/24/24.
//

import Foundation

struct CrCircle: Codable, Identifiable, Equatable {
    var id: UUID
    var created_at: Date
    var title: String
    var owner_id: UUID
    
    var owner: Profile?
}

struct CircleCreate: Codable {
    var title: String
}
