//
//  VerifyEmailView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct VerifyEmailSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("We sent a link \nto your email")
                    .font(.rubicBoldFont(size: 44))
                    .fontWeight(.bold)
                
                Text("Click it to verify the email address")
                    .font(.interLightFont(size: 14))
                    .foregroundColor(CustomColors.darkGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Spacer()
        }
    }
}

struct VerifyEmailSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyEmailSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
