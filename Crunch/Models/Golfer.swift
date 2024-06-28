//
//  Golfer.swift
//  Crunch
//
//  Created by Henry Spindell on 6/15/24.
//

import Foundation

struct Golfer: Codable, Identifiable, Equatable {
    var id: String { pga_id }
    
    var pga_id: String
    var first_name: String
    var last_name: String
    var rank: Int?
    var avatar_url: String?
    var avatarURL: URL? { avatar_url?.url }
    var country: String
    
    static let flagCodeMapping = [
        "ARG": "ar",
        "AUS": "au",
        "AUT": "at",
        "BEL": "be",
        "CAN": "ca",
        "CHI": "cl",
        "DEN": "dk",
        "ENG": "gb-eng",
        "ESP": "es",
        "FIN": "fi",
        "FRA": "fr",
        "GER": "de",
        "IRL": "ie",
        "JPN": "jp",
        "KOR": "kr",
        "NIR": "gb-nir",
        "NOR": "no",
        "NZL": "nz",
        "POL": "pl",
        "RSA": "za",
        "SCO": "gb-sct",
        "SWE": "se",
        "TPE": "tw",
        "USA": "us",
    ]
    
    var flagCode: String? {
        Self.flagCodeMapping[country]
    }
}

extension Golfer {
    // "https://wallpapers.com/images/hd/person-profile-silhouette-2r2paistadhraxdt.jpg"
    static let obscured = Golfer(pga_id: "", first_name: "", last_name: "_", rank: 1, avatar_url: nil, country: "")
    
    static let sample = Golfer(pga_id: "12345", first_name: "Scottie", last_name: "Scheffler", rank: 1, avatar_url: "https://pga-tour-res.cloudinary.com/image/upload/c_thumb,g_face,w_280,h_280,z_0.7/headshots_46046.jpg", country: "USA")
}
