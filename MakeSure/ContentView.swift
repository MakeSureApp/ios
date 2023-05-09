//
//  ContentView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
import NavigationStack

struct ContentView: View {
    @ObservedObject private var authService: AuthService

    init() {
        _authService = Self.createAuthServiceObservedObject()
    }
        
    private static func createAuthServiceObservedObject() -> ObservedObject<AuthService> {
        return ObservedObject(wrappedValue: appEnvironment.authService)
    }

    var body: some View {
        switch authService.authState {
            case .isLoggedIn:
                MainTabView()
                    .environmentObject(appEnvironment)
            case .isLoggedOut:
                NavigationView {
                    InitialSelectionView()
                        .environmentObject(appEnvironment)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
