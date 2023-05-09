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
    private lazy var testsViewModel = TestsViewModel()
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func getMainViewModel() -> MainViewModel {
        return mainViewModel
    }
    
    func getHomeViewModel() -> HomeViewModel {
        return homeViewModel
    }
    
    func getLoginViewModel() -> LoginViewModel {
        return loginViewModel
    }
    
    func getRegistrationViewModel() -> RegistrationViewModel {
        return registrationViewModel
    }
    
    func getSettingsViewModel() -> SettingsViewModel {
        return settingsViewModel
    }
    
    func getContactsViewModel() -> ContactsViewModel {
        return contactsViewModel
    }
    
    func getTestsViewModel() -> TestsViewModel {
        return testsViewModel
    }
    
    // Add factory methods for other view models
}
