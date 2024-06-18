//
//  ContentView.swift
//  Crunch
//
//  Created by Henry Spindell on 4/11/24.
//

import SwiftUI
import SwiftData

import Supabase

let supabase = SupabaseClient(supabaseURL: URL(string: "https://arsfsniyfuubvmnwxhvh.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyc2Zzbml5ZnV1YnZtbnd4aHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM1NTg3MzQsImV4cCI6MjAyOTEzNDczNH0.XLSfAlrkG1PydgkUBswpV7cIQ0uFyDBDa-Hmltyh7UY")

struct ContentView: View {
    var body: some View {
        LandingPage()
    }
}

#Preview {
    ContentView()
}
