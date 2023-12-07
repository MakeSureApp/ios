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

    private let supabaseUrl = Constants.supabaseUrl
    private let supabaseKey = Constants.supabaseKey
    private let supabaseServiceKey = Constants.supabaseServiceKey
    let supabase: SupabaseClient
    let supabaseRealtime: RealtimeClient
    
    private let serverUrl = Constants.serverUrl
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
    
    func storageClient(bucketName: String = "user_images") async -> StorageFileApi? {
//        guard let jwt = try? await supabase.auth.session.accessToken else {
//            print("couldn't access auth")
//            return nil}
        return SupabaseStorageClient(
            url: "\(supabaseUrl)/storage/v1",
            headers: [
                "Authorization": "Bearer \(supabaseServiceKey)",
                "apikey": supabaseKey,
            ]
        ).from(id: bucketName)
    }
}
