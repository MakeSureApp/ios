//
//  MainViewModel.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import SwiftUI

enum MainNavigation: CaseIterable {
    static var allCases: [MainNavigation] {
        return [.home(viewModel: HomeViewModel(authService: AuthService())), .tests, .scanner, .contacts]
    }
    case home(viewModel: HomeViewModel)
    case tests
    case scanner
    case contacts
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .home(let viewModel):
            HomeView(viewModel: viewModel)
        case .tests:
            TestsView()
        case .scanner:
            ScannerView()
        case .contacts:
            ContactsView()
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
            return "Home"
        case .tests:
            return "Tests"
        case .scanner:
            return "Scan"
        case .contacts:
            return "Contacts"
        }
    }
}

class MainViewModel: ObservableObject {
    
    @ObservedObject var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
}
