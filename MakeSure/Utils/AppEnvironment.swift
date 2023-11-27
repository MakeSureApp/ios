//
//  AppEnviroment.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import Foundation
import SwiftUI

let appEnvironment = AppEnvironment()
class AppEnvironment: ObservableObject {
    
    @Published var authService = AuthService()
    private(set) lazy var deeplinkHandler = DeeplinkHandler(authService: authService)
    private(set) lazy var viewModelFactory = ViewModelFactory(authService: authService)
    private(set) lazy var networkManager = NetworkManager()
    private(set) lazy var localizationManager = LocalizationManager()
    
    let onesignal_app_id = "bae4b484-acfa-418b-b5f7-c74da3ffe78b"
}
