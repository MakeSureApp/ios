//
//  ConnectAppleSignUpView.swift
//  MakeSure
//
//  Created by Macbook Pro on 24.08.2023.
//

import SwiftUI

struct LinkAppleSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ConnectAppleSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        LinkAppleSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
