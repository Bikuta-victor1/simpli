//
//  Configuration.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

struct Configuration {
    // TODO: Replace with your Supabase project URL
    // Format: https://YOUR_PROJECT_REF.supabase.co/functions/v1/explain
    static let baseURL = "https://YOUR_PROJECT_REF.supabase.co/functions/v1/explain"
    
    // TODO: Replace with your Supabase anon key from dashboard
    static let supabaseAnonKey = "YOUR_ANON_KEY"
    
    static var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "apikey": supabaseAnonKey,
            "Authorization": "Bearer \(supabaseAnonKey)"
        ]
    }
}
