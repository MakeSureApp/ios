//
//  AuthService.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation

enum AuthType {
    case signIn
    case signUp
}

class AuthService: ObservableObject {
    
    enum AuthState {
        case isLoggedIn(UserModel)
        case isLoggedOut
    }
    
    private static let userKey = "loggedInUser"
    
    @Published var authState: AuthState
    
    init() {
        authState = .isLoggedIn(UserModel(id: UUID(), name: "Joyce", birthdate: Date(), sex: "female", phone: "+79001234567"))
//        if let user = AuthService.getUserFromUserDefaults() {
//            authState = .isLoggedIn(user)
//        } else {
//            authState = .isLoggedOut
//        }
    }
    
    private func saveUserToUserDefaults(user: UserModel) {
        if let encodedData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedData, forKey: AuthService.userKey)
        }
    }
    
    private func removeUserFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: AuthService.userKey)
    }
    
    private static func getUserFromUserDefaults() -> UserModel? {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            return user
        }
        return nil
    }
}
