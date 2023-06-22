//
//  DeeplinkHandler.swift
//  MakeSure
//
//  Created by Macbook Pro on 21.06.2023.
//

import Foundation
import SwiftUI

class DeeplinkHandler: ObservableObject {
    @Published var deeplinkNavigation: DeeplinkNavigation? {
        didSet {
            handleDeeplinkNavigationChange()
        }
    }

    @ObservedObject private var authService: AuthService
    @Published var addToContactWithUserId: String? = nil

    init(authService: AuthService) {
        self.authService = authService
    }

    private func handleDeeplinkNavigationChange() {
        guard let deeplinkNavigation else { return }

        switch deeplinkNavigation {
        case .setUsername:
            if case .isLoggedIn(let user) = authService.authState {
                sendUserIdBackToPureApp(userId: user.id.uuidString)
            }
        case .addContact(let userId):
            addToContactWithUserId = userId;
        default:
            break
        }
    }

    private func sendUserIdBackToPureApp(userId: String) {
        if let url = URL(string: "DiplinkTest://\(userId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
