//
//  HomeViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @ObservedObject var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func signOutBtnClicked() {
        authService.authState = .isLoggedOut
    }
}
