//
//  Contact.swift
//  MakeSure
//
//  Created by andreydem on 4/27/23.
//

import Foundation
import SwiftUI

struct User: Identifiable, Hashable {
    let id: UUID
    let name: String
    let dates: [UUID : [Date]]
    let testsData: [Date : [Test]]
    let image: UIImage
    let followedDate: Date
}

struct UserModel: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var birthdate: Date
    var sex: String
    var phone: String
    var email: String?
    var blockedUsers: [UUID]?
    var contacts: [UUID]?
    var photoUrl: String?
    var image: UIImage? = nil
    //let followedDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, name, birthdate = "date_of_birth", sex, phone, email, blockedUsers = "blocked_users", contacts, photoUrl = "photo_URL"
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    mutating func loadImage() async {
        guard let photoUrl, let url = URL(string: photoUrl) else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            image = UIImage(data: data)
        } catch {
            print("Error loading user image: \(error.localizedDescription)")
        }
    }
}

struct UserApple: Codable {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
}

struct OTPResponse: Codable {
    let status: String
    let mobile: String?
    let transactionId: String?
    let statusCode: String
    let type: String?
    let reason: String
    let createTime: String?
    let expiryTime: String?
    let retryAfter: String?
}

enum ImageError: Error {
    case jpegConversionFailed
}
