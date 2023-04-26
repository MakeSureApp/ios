//
//  ViewModelFactory.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import Foundation

class ViewModelFactory {
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func makeMainViewModel() -> MainViewModel {
        return MainViewModel(authService: authService)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel()
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authService: authService)
    }
    
    func makeRegistrationViewModel() -> RegistrationViewModel {
        return RegistrationViewModel(authService: authService)
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(authService: authService)
    }
    
    func makeContactsViewModel() -> ContactsViewModel {
        return ContactsViewModel()
    }
    
    // Add factory methods for other view models
}
