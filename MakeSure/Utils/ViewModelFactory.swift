//
//  ViewModelFactory.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import Foundation

class ViewModelFactory {
    private let authService: AuthService
    private lazy var mainViewModel = MainViewModel(authService: authService)
    private lazy var homeViewModel = HomeViewModel()
    private lazy var loginViewModel = LoginViewModel(authService: authService)
    private lazy var registrationViewModel = RegistrationViewModel(authService: authService)
    private lazy var settingsViewModel = SettingsViewModel(authService: authService)
    private lazy var contactsViewModel = ContactsViewModel()
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func makeMainViewModel() -> MainViewModel {
        return mainViewModel
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return homeViewModel
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return loginViewModel
    }
    
    func makeRegistrationViewModel() -> RegistrationViewModel {
        return registrationViewModel
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return settingsViewModel
    }
    
    func makeContactsViewModel() -> ContactsViewModel {
        return contactsViewModel
    }
    
    // Add factory methods for other view models
}
