//
//  AppleSignInView.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import SwiftUI

struct AppleSignInView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AppleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        AppleSignInView(viewModel: LoginViewModel(authService: AuthService()))
    }
}
