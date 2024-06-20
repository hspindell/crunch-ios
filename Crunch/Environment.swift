//
//  Environment.swift
//  Crunch
//
//  Created by Henry Spindell on 6/20/24.
//

import Foundation

enum Env {
    case dev, prod
    static var current = Env.dev
    static var isDev: Bool { current == .dev }
    static var supabaseUrl: String {
        isDev ? "https://arsfsniyfuubvmnwxhvh.supabase.co" : "https://udsnsgirpuaqnfpamcpw.supabase.co"
    }
    static var branchBase: String {
        isDev ? "https://qanku.test-app.link/" : "https://crunchpools.com"
    }
    static var supabaseKey: String {
        isDev ? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyc2Zzbml5ZnV1YnZtbnd4aHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM1NTg3MzQsImV4cCI6MjAyOTEzNDczNH0.XLSfAlrkG1PydgkUBswpV7cIQ0uFyDBDa-Hmltyh7UY" :
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkc25zZ2lycHVhcW5mcGFtY3B3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg5MDQxMDksImV4cCI6MjAzNDQ4MDEwOX0.pp80oBQThK3anzSuoC4qUB24z-uAj-z4xyvVn1NQIF0"
    }
}
