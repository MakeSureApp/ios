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
    private(set) lazy var viewModelFactory = ViewModelFactory(authService: authService)
    private(set) lazy var supabaseManager = SupabaseManager()
    private(set) lazy var localizationManager = LocalizationManager()
    
}
