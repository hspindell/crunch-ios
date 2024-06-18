//
//  AppObject.swift
//  Crunch
//
//  Created by Henry Spindell on 5/24/24.
//

import Foundation

class AppObject: ObservableObject, Identifiable {
    @Published var userProfile: Profile
    @Published var circles = [CrCircle]()
    @Published var deepLinkPoolId: String?
    @Published var deepLinkCircleId: String?
    
    /// Handles the incoming URL and performs validations before acknowledging.
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "crunchapp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid deep link URL")
            return
        }

        guard let actionRaw = components.host, let action = DeepLink.Action(rawValue: actionRaw) else {
            print("Unknown deep link action")
            return
        }

        guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Deep link ID not found")
            return
        }
        
        clearDeepLinks()
        
        if action == .joinCircle {
            deepLinkCircleId = id
        } else if action == .joinPool {
            deepLinkPoolId = id
        }
    }
    
    func clearDeepLinks() {
        deepLinkPoolId = nil
        deepLinkCircleId = nil
    }
    
    init(userProfile: Profile, pendingDeepLinkURL: URL? = nil) {
        self.userProfile = userProfile
        if let pendingDeepLinkURL {
            handleIncomingURL(pendingDeepLinkURL)
        }
    }
}

class DeepLink {
    enum Action: String {
        case joinCircle = "join-circle"
        case joinPool = "join-pool"
    }
    
    static func build(action: Action, params: [URLQueryItem] = []) -> String {
        // TODO fix to use branch link
        let queryString = params.compactMap { item in
            guard let val = item.value else { return nil }
            return "\(item.name)=\(val)"
        }.joined(separator: "&")
        // TODO fix for prod environment
        // and use crunchpools.com domain
        return "https://qanku.test-app.link/\(action.rawValue)?\(queryString)"
    }
}
