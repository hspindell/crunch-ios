//
//  CrunchApp.swift
//  Crunch
//
//  Created by Henry Spindell on 4/11/24.
//

import SwiftUI
import SwiftData
import BranchSDK

@main
struct CrunchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    Branch.getInstance().handleDeepLink(url)
                })
        }
    }
}
