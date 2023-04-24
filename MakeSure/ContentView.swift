//
//  ContentView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
import NavigationStack

struct ContentView: View {
    @StateObject var authService = AuthService()

    var body: some View {
            switch authService.authState {
            case .isLoggedIn:
                MainTabView(viewModel: MainViewModel(authService: authService))
            case .isLoggedOut:
                NavigationView {
                    InitialSelectionView(registrationViewModel: RegistrationViewModel(authService: authService), loginViewModel: LoginViewModel(authService: authService))
                }
            }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
