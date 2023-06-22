//
//  SupabaseManager.swift
//  MakeSure
//
//  Created by andreydem on 5/3/23.
//

import Foundation
import Supabase
import Realtime

class SupabaseManager {

    private let supabaseUrl = URL(string: "https://yxhzpmbfylvoizdcwkpa.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4aHpwbWJmeWx2b2l6ZGN3a3BhIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODI5MzY5MDMsImV4cCI6MTk5ODUxMjkwM30.J3MUrMX6RoO1ek-e336zEfKNKu8fI0MaZqb_NQlFLg8"
    let supabase: SupabaseClient
    let supabaseRealtime: RealtimeClient

    init() {
        supabase = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
        supabaseRealtime = RealtimeClient(endPoint: "\(supabaseUrl)/realtime/v1", params: ["apikey": supabaseKey])
    }
}
