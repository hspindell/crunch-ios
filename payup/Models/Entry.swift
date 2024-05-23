//
//  Entry.swift
//  payup
//
//  Created by Henry Spindell on 5/16/24.
//

import Foundation

struct Entry: Codable, Identifiable {
    var id: String { profile_id.uuidString + pool_id.uuidString }
    var profile_id: UUID
    var pool_id: UUID
    var created_at: Date?
    var complete: Bool
    var title: String
    var picks: JSON?
    
    var profile: Profile?
}

struct EntryCreation: Encodable {
    var pool_id: UUID
    var title: String
}

//protocol EntryProtocol: Codable, Identifiable {
//    var profile_id: UUID { get }
//    var pool_id: UUID { get }
//    var created_at: Date { get }
//    var complete: Bool { get }
//    var title: String { get }
//    
//    var profile: Profile? { get set }
//}
//
//extension EntryProtocol {
//    var id: String {
//        "\(pool_id)-\(profile_id)"
//    }
//}
//
//struct AnyEntry: EntryProtocol {
//    var profile_id: UUID
//    var profile: Profile?
//    var pool_id: UUID
//    var created_at: Date
//    var complete: Bool
//    var title: String
//}
//
//struct GolfPickSixEntry: EntryProtocol {
//    var profile_id: UUID
//    var profile: Profile?
//    var pool_id: UUID
//    var created_at: Date
//    var complete: Bool {
//        picks?.count == 6 && picks?.allSatisfy({ $0 != nil }) == true
//    }
//    var title: String
//
//    var picks: [Int?]?
//}
