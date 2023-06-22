//
//  MainViewModel.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import SwiftUI

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
            return (22, 24)
        case .tests:
            return (31, 32)
        case .scanner:
            return (27, 27)
        case .contacts:
            return (33, 27)
        }
    }
}

class MainViewModel: ObservableObject {
    
    @ObservedObject var authService: AuthService = appEnvironment.authService
    @Published var user: UserModel?
    //@Published var userId: UUID = UUID(uuidString: "4239D90A-E8F0-11ED-A05B-0242AC120003")! // Yennefer
    @Published var userId: UUID = UUID(uuidString: "79295454-E8F0-11ED-A05B-0242AC120003")! // Geralt
    //@Published var userId: UUID = UUID(uuidString: "70cbf4a2-e8ef-11ed-a05b-0242ac120003")! // Joyce
    
    @Published var currentTab: MainNavigation = .home
}
