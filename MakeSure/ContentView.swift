//
//  ContentView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
struct ContentView: View {

    @ObservedObject private var authService = appEnvironment.authService
    
//    @ObservedObject private var authService: AuthService
//
//    init() {
//        _authService = Self.createAuthServiceObservedObject()
//    }
//
//    private static func createAuthServiceObservedObject() -> ObservedObject<AuthService> {
//        return ObservedObject(wrappedValue: appEnvironment.authService)
//    }

    @ViewBuilder
    var body: some View {
        switch authService.authState {
        case .isLoggedIn:
            MainTabView()
                .environmentObject(appEnvironment)
           
        case .isLoggedOut:
            NavigationView {
                InitialSelectionView()
                    .environmentObject(appEnvironment)
                    .navigationBarHidden(true)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
