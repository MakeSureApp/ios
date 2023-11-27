//
//  SupabaseService.swift
//  MakeSure
//
//  Created by andreydem on 5/3/23.
//

import Foundation
import Supabase
import Realtime
import SupabaseStorage
import UIKit

class SupabaseService<T: Codable> {
    
    let supabase: SupabaseClient
    var supabaseRealtime: RealtimeClient
    let tableName: String
   
    
    init(tableName: String) {
        self.tableName = tableName
        
        supabase = appEnvironment.networkManager.supabase
        
        supabaseRealtime = appEnvironment.networkManager.supabaseRealtime
        
//        supabaseRealtime.connect()
//        supabaseRealtime.onOpen { print("Socket opened.") }
//        supabaseRealtime.onError { error in print("Socket error: ", error.localizedDescription) }
//        supabaseRealtime.onClose { print("Socket closed") }
    }
    
    func fetchAll() async throws -> [T] {
        let response: [T] = try await supabase.database.from(tableName).select().execute().value
        return response
    }
    
    func fetchById(columnName: String, id: UUID) async throws -> [T] {
        let response: [T] = try await supabase.database.from(tableName).select().eq(column: columnName, value: id).execute().value
        return response
    }
    
    func create(item: T) async throws {
        try await supabase.database.from(tableName).insert(values: item).execute().value
    }
    
    func update<U: Encodable>(id: UUID, fields: U) async throws {
        try await supabase.database.from(tableName).update(values: fields).eq(column: "id", value: id).execute().value
    }
    
    func delete(id: UUID) async throws {
        try await supabase.database.from(tableName).delete().eq(column: "id", value: id).execute()
    }
    
    func subscribeToChanges(columnName: String, value: String, callback: @escaping ([T]?) -> Void) {
        let channel = supabaseRealtime.channel(.column(columnName, value: value, table: tableName, schema: "public"))
        channel.on(.all) { message in
            DispatchQueue.main.async {
                let decoder = JSONDecoder()
                if let data = try? JSONSerialization.data(withJSONObject: message.payload, options: []),
                   let model = try? decoder.decode([T].self, from: data) {
                    callback(model)
                } else {
                    callback(nil)
                }
            }
        }
         channel.subscribe()
     }

     func unsubscribeFromChanges(columnName: String, value: String) {
         let channel = supabaseRealtime.channel(.column(columnName, value: value, table: tableName, schema: "public"))
         channel.off(.all)
         channel.unsubscribe()
     }

     func disconnect() {
         supabaseRealtime.disconnect()
     }
    
}

class UserSupabaseService: SupabaseService<UserModel> {
    init() {
        super.init(tableName: "users")
    }
    
    func fetchUsersByUserId(userId: UUID) async throws -> [UserModel] {
        return try await fetchById(columnName: "id", id: userId)
    }
    
    func fetchUserById(id: UUID) async throws -> UserModel? {
        let response: [UserModel] = try await supabase.database.from(tableName).select().eq(column: "id", value: id).execute().value
        return response.first
    }
    
    func fetchUserByPhone(phone: String) async throws -> UserModel? {
        let response: [UserModel] = try await fetchAll()
        if let user = response.first(where: { $0.phone == phone }) {
            return user
        }
        return nil
    }
    
    func fetchUserByEmail(email: String) async throws -> UserModel? {
        let response: [UserModel] = try await fetchAll()
        if let user = response.first(where: { $0.email == email }) {
            return user
        }
        return nil
    }
    
    func uploadUserImage(_ image: UIImage, userId: UUID) async throws -> String? {
        guard let data = image.pngData() else {
            throw ImageError.jpegConversionFailed
        }
        
        let fileName = "test.png"
        let filePath = "profile_photo/\(fileName)"
        let file = File(name: fileName, data: data, fileName: fileName, contentType: "image/png")
        let storageClient = await appEnvironment.networkManager.storageClient()
        let result = try await storageClient?.upload(path: fileName, file: file, fileOptions: FileOptions(cacheControl: "3600"))
        print("uploaded file = \(result ?? "empty")")
        
        let photoURL = fullImageURL(for: filePath)
        
        return photoURL
    }
    
    func fullImageURL(for relativePath: String) -> String {
        let baseURL = "https://profile_photo.supabase.co/storage/v1/object/public/"
        return baseURL + relativePath
    }
}

class MeetingSupabaseService: SupabaseService<MeetingModel> {
    init() {
        super.init(tableName: "meetings")
    }
    
    func fetchMeetingsByUserId(userId: UUID) async throws -> [MeetingModel] {
        return try await fetchById(columnName: "user_id", id: userId)
    }
}

class TestSupabaseService: SupabaseService<TestModel> {
    init() {
        super.init(tableName: "tests")
    }
    
    func fetchTestsByUserId(userId: UUID) async throws -> [TestModel] {
        return try await fetchById(columnName: "user_id", id: userId)
    }
}

class TipsSupabaseService: SupabaseService<TipsModel> {
    init() {
        super.init(tableName: "tips")
    }
}

class FriendsLinksSupabaseService: SupabaseService<FriendLinkModel> {
    init() {
        super.init(tableName: "friend_links")
    }
    
    func fetchLinksByUserId(userId: UUID) async throws -> [FriendLinkModel] {
        return try await fetchById(columnName: "user_id", id: userId)
    }
    
    func fetchLinksById(id: UUID) async throws -> [FriendLinkModel] {
        return try await fetchById(columnName: "id", id: id)
    }
}

class NotificationsSupabaseService: SupabaseService<NotificationModel> {
    init() {
        super.init(tableName: "notifications")
    }
    
    func fetchNotificationsByUserId(userId: UUID) async throws -> [NotificationModel] {
        return try await fetchById(columnName: "user_id", id: userId)
    }
    
    func subscribeToUserIdChanges(userId: UUID, callback: @escaping ([NotificationModel]?) -> Void) {
        subscribeToChanges(columnName: "user_id", value: userId.uuidString, callback: callback)
    }

    func unsubscribeFromUserIdChanges(userId: UUID) {
        unsubscribeFromChanges(columnName: "user_id", value: userId.uuidString)
    }
}


class AuthSupabaseService {
    
    private let supabase: SupabaseClient
    
    init() {
        self.supabase = appEnvironment.networkManager.supabase
    }
    
    func authWithPhoneNumber(phoneNumber: String, otp: String, type: AuthType) async throws -> UUID? {
        let response = try await supabase.auth.verifyOTP(phone: phoneNumber, token: otp, type: type == .signIn ? .sms : .signup)
        
        return response.user?.id
    }
    
    
    func sendOTP(phoneNumber: String) async throws {
        //        let response = await supabase.auth.sendOTP(phone: phoneNumber)
        //
        //        switch response {
        //        case .success(_):
        //            print("OTP sent successfully")
        //        case .failure(let error):
        //            throw error
        //        }
    }
    
    func authWithApple(idToken: String, nonce: String) async throws -> UUID? {
        let response = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
        return response.user.id
    }
    
    func currentUserId() async -> UUID? {
        var id: UUID?
        do {
            id = try await supabase.auth.session.user.id
        } catch {
            print("AuthSupabaseService: Error: Unable to get user id")
        }
        return id
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
