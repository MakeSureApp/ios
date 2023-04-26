//
//  ContentView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
import NavigationStack

struct ContentView: View {
    @StateObject private var appEnvironment = AppEnvironment()
    @ObservedObject private var authService: AuthService

    init() {
        let appEnvironment = AppEnvironment()
        _appEnvironment = StateObject(wrappedValue: appEnvironment)
        _authService = Self.createAuthServiceObservedObject(from: appEnvironment)
    }
        
    private static func createAuthServiceObservedObject(from appEnvironment: AppEnvironment) -> ObservedObject<AuthService> {
        return ObservedObject(wrappedValue: appEnvironment.authService)
    }

    var body: some View {
        switch authService.authState {
            case .isLoggedIn:
                MainTabView(appEnvironment: appEnvironment)
                    .environmentObject(appEnvironment)
            case .isLoggedOut:
                NavigationView {
                    InitialSelectionView(appEnvironment: appEnvironment)
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
