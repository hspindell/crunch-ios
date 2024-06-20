//
//  AppDelegate.swift
//  Crunch
//
//  Created by Henry Spindell on 6/20/24.
//

import SwiftUI
import BranchSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
            // Access and use Branch Deep Link data here (nav to page, display content, etc.)
            
        }
//        Branch.getInstance().validateSDKIntegration()

        return true
    }
}
