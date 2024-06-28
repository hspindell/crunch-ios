//
//  Environment.swift
//  Crunch
//
//  Created by Henry Spindell on 6/20/24.
//

import Foundation
import Supabase

#if DEBUG
var supabase = initSupabase()
let debug = true

func initSupabase() -> SupabaseClient {
    SupabaseClient(supabaseURL: Env.current.supabaseURL, supabaseKey: Env.current.supabaseKey)
}
#else
let supabase = SupabaseClient(supabaseURL: Env.prod.supabaseURL, supabaseKey: Env.prod.supabaseKey)
let debug = false
#endif

enum Env {
    case dev, prod
    
    #if DEBUG
    static var current = Env.dev
    static var isDev: Bool { current == .dev }
    #else
    static let current = Env.prod
    static let isDev = false
    #endif
    
    var supabaseURL: URL {
        if self == .dev {
            return "https://arsfsniyfuubvmnwxhvh.supabase.co".url!
        } else {
            return "https://udsnsgirpuaqnfpamcpw.supabase.co".url!
        }
    }
    
    var supabaseKey: String {
        if self == .dev {
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyc2Zzbml5ZnV1YnZtbnd4aHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM1NTg3MzQsImV4cCI6MjAyOTEzNDczNH0.XLSfAlrkG1PydgkUBswpV7cIQ0uFyDBDa-Hmltyh7UY"
        } else {
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkc25zZ2lycHVhcW5mcGFtY3B3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg5MDQxMDksImV4cCI6MjAzNDQ4MDEwOX0.pp80oBQThK3anzSuoC4qUB24z-uAj-z4xyvVn1NQIF0"
        }
    }
    
    var branchBase: String {
        if self == .dev {
            return "https://crunchpools.test-app.link"
        } else {
            return "https://crunchpools.app.link"
        }
    }
}
