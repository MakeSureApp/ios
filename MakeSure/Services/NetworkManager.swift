//
//  SupabaseManager.swift
//  MakeSure
//
//  Created by andreydem on 5/3/23.
//

import Foundation
import Supabase
import Realtime
import SupabaseStorage

class NetworkManager {

    private let supabaseUrl = URL(string: "http://82.146.56.214:8000")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"
    let supabase: SupabaseClient
    let supabaseRealtime: RealtimeClient
    
    private let serverUrl = URL(string: "http://82.146.56.214:3080")!
    private let serverTestResultEndpoint = "test_results_detection"
//    private let workhorseUrl = URL(string: "http://82.146.56.214:3080")!

    init() {
        supabase = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
        supabaseRealtime = RealtimeClient(endPoint: "\(supabaseUrl)/realtime/v1", params: ["apikey": supabaseKey])
    }
    
    func getTestResultUrl() -> URL {
        var url = serverUrl
        url.append(component: serverTestResultEndpoint)
        return url
    }
    
    func storageClient(bucketName: String = "profile_photo") async -> StorageFileApi? {
        let jwt = "gxg5daofx6hwxcZnp/NxPRiJ62EnbfOc4Uc9AVvRD+Vf+RgQYFXL9ttESFkqi1VMaSQEmlTwo/ZeKhDtj+PKeQ=="
        return SupabaseStorageClient(
            url: "\(supabaseUrl)/storage/v1/object/public",
            headers: [
                "Authorization": "Bearer \(jwt)",
                "apikey": supabaseKey,
            ]
        ).from(id: bucketName)
    }
}
