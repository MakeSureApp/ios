//
//  SupabaseService.swift
//  MakeSure
//
//  Created by andreydem on 5/3/23.
//

import Foundation
import Supabase

class SupabaseService<T: Codable> {
    
    let supabase: SupabaseClient
    let tableName: String
    
    init(tableName: String) {
        supabase = appEnvironment.supabaseManager.supabase
        self.tableName = tableName
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
