//
//  MainViewModel.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import SwiftUI
import Combine
import OneSignalFramework

enum MainNavigation: CaseIterable {
    case home
    case tests
    case scanner
    case contacts
    
    @ViewBuilder
    func destinationView(viewModelFactory: ViewModelFactory) -> some View {
        switch self {
        case .home:
            HomeView()
                .environmentObject(viewModelFactory.getHomeViewModel())
        case .tests:
            TestsView()
                .environmentObject(viewModelFactory.getTestsViewModel())
                .environmentObject(viewModelFactory.getContactsViewModel())
        case .scanner:
            ScannerView()
                .environmentObject(viewModelFactory.getScannerViewModel())
                .environmentObject(viewModelFactory.getContactsViewModel())
                .environmentObject(viewModelFactory.getMainViewModel())
        case .contacts:
            ContactsView()
                .environmentObject(viewModelFactory.getContactsViewModel())
                .environmentObject(viewModelFactory.getTestsViewModel())
        }
    }
    
    var imageName: String {
        switch self {
        case .home:
            return "homeTabIcon"
        case .tests:
            return "testsTabIcon"
        case .scanner:
            return "scanTabIcon"
        case .contacts:
            return "contactsTabIcon"
        }
    }
    
    var name: String {
        switch self {
        case .home:
            return "home_tab".localized
        case .tests:
            return "tests_tab".localized
        case .scanner:
            return "scan_tab".localized
        case .contacts:
            return "contacts_tab".localized
        }
    }
    
    var imageSize: (width: CGFloat, height: CGFloat) {
        switch self {
        case .home:
            return (26, 26)
        case .tests:
            return (26, 26)
        case .scanner:
            return (26, 26)
        case .contacts:
            return (26, 26)
        }
    }
}

class MainViewModel: NSObject, ObservableObject {
    
    @ObservedObject var authService: AuthService = appEnvironment.authService
    
    @Published var user: UserModel?
    @Published var userId: UUID?
    
    //@Published var userId: UUID = UUID(uuidString: "4239D90A-E8F0-11ED-A05B-0242AC120003")! // Yennefer
    //@Published var userId: UUID = UUID(uuidString: "79295454-E8F0-11ED-A05B-0242AC120003")! // Geralt
    //@Published var userId: UUID = UUID(uuidString: "70cbf4a2-e8ef-11ed-a05b-0242ac120003")! // Joyce
    
    @Published var currentTab: MainNavigation = .home
    @Published var showOrderBoxView: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupObservers()
    }
    
    private func setupObservers() {
        authService.$authState.sink { [weak self] state in
            switch state {
            case .isLoggedIn(let loggedInUser):
                self?.user = loggedInUser
                self?.userId = loggedInUser.id
                OneSignal.login(loggedInUser.id.uuidString)
            case .isLoggedOut:
                self?.user = nil
                self?.userId = nil
                OneSignal.logout();
            }
        }.store(in: &cancellables)
    }
}
