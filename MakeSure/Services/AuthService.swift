//
//  AuthService.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation

class AuthService: ObservableObject {
    
    enum AuthState {
        case isLoggedIn
        case isLoggedOut
    }
    
    @Published var authState: AuthState = .isLoggedOut
    
}
