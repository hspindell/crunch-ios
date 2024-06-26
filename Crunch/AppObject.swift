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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid deep link URL")
            return
        }
        var rawAction: String
        
        if url.scheme == "crunchapp" {
            rawAction = components.host ?? ""
        } else if url.absoluteString.starts(with: Env.current.branchBase) {
            rawAction = components.path.replacingOccurrences(of: "/", with: "")
        } else {
            print("App opened by unrecognized source URL")
            return
        }

        guard let action = DeepLink.Action(rawValue: rawAction) else {
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
    
    func handlePush(data: [String : Any]) {
        if let circleId = data["circle_id"] as? String {
            deepLinkCircleId = circleId
        } else if let poolId = data["pool_id"] as? String {
            deepLinkPoolId = poolId
        }
    }
    
    func clearDeepLinks() {
        deepLinkPoolId = nil
        deepLinkCircleId = nil
    }
    
    init(userProfile: Profile, pendingDeepLinkURL: URL? = nil, pendingPushData: [String : Any]? = nil) {
        self.userProfile = userProfile
        if let pendingDeepLinkURL {
            handleIncomingURL(pendingDeepLinkURL)
        } else if let pendingPushData {
            handlePush(data: pendingPushData)
        }
    }
}

class DeepLink {
    enum Action: String {
        case joinCircle = "join-circle"
        case joinPool = "join-pool"
    }
    
    static func build(action: Action, params: [URLQueryItem] = []) -> String {
        let queryString = params.compactMap { item in
            guard let val = item.value else { return nil }
            return "\(item.name)=\(val)"
        }.joined(separator: "&")
        return "\(Env.current.branchBase)/\(action.rawValue)?\(queryString)"
    }
}
