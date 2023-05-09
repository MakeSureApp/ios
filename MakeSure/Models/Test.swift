//
//  Test.swift
//  MakeSure
//
//  Created by andreydem on 4/28/23.
//

import Foundation

struct Test: Identifiable, Hashable {
    var id: UUID
    var name: String
}

struct TestModel: Codable, Identifiable, Hashable {
    var id: UUID
    var packageId: UUID
    var userId: UUID?
    var date: Date?
    var name: String
    var result: String?
    var isActivated: Bool
    var photoUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, packageId = "package_id", userId = "user_id", date = "date_time", name = "infection_type", result, isActivated = "is_activated", photoUrl = "test_photoURL"
    }
}
