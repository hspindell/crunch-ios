//
//  ContentView.swift
//  Crunch
//
//  Created by Henry Spindell on 4/11/24.
//

import SwiftUI
import SwiftData

import Supabase

let supabase = SupabaseClient(supabaseURL: Env.supabaseUrl.url!, supabaseKey: Env.supabaseKey)

struct ContentView: View {
    var body: some View {
        LandingPage()
    }
}

#Preview {
    ContentView()
}
