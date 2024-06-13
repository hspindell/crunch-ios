//
//  Event.swift
//  Crunch
//
//  Created by Henry Spindell on 6/13/24.
//

import Foundation

struct Event: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var logo_url: String?
    var cover_image_url: String?
    var starts_at: Date
    var external_id: String?
    
    var logoURL: URL? { logo_url?.url }
    var coverImageURL: URL? { cover_image_url?.url }
    
    var started: Bool {
        return Date() > starts_at
    }
    
    var lockDateDisplay: String? {
//        guard let starts_at else { return nil }
        return starts_at.formatted(.dateTime.weekday(.wide).month().day().hour().minute().timeZone())
    }
}

extension Event {
    static let sample = Event(id: .init(), title: "Event A", logo_url: "https://res.cloudinary.com/pgatour-prod/d_tournaments:logos:r000.png/tournaments/logos/r032.png", cover_image_url: "https://res.cloudinary.com/pgatour-prod/c_crop/d_placeholders:tournamentBackgroundSolid.png/pgatour/courses/r032/874/holes/hole18.jpg", starts_at: Date())
}
