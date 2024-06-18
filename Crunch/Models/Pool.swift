//
//  Pool.swift
//  Crunch
//
//  Created by Henry Spindell on 6/14/24.
//

import Foundation

struct Pool: Codable, Identifiable {
    var id: UUID
    var created_at: Date
    var circle_id: UUID?
    var admin_id: UUID
    var event_id: UUID
    var title: String
    var details: String?
    var pool_type: String
    var is_public: Bool
    
    var events: Event?
    var event: Event? { events }
    
    var poolType: PoolType? {
        PoolType(rawValue: pool_type)
    }
    enum PoolType: String, Codable {
        case golfPickSix = "golf-pick-six"
    }
}

struct PoolCreate: Codable {
    var circle_id: UUID?
    var event_id: UUID
    var title: String
    var details: String?
    var pool_type: Pool.PoolType
    var is_public: Bool
}

extension Pool {
    static let sample = Pool(id: UUID(), created_at: Date(), admin_id: UUID(), event_id: Event.sample.id, title: "Banana Pool", pool_type: PoolType.golfPickSix.rawValue, is_public: true)
}
