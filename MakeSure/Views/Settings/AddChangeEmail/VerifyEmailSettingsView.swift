//
//  VerifyEmailSettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI

struct VerifyEmailSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

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

struct VerifyEmailSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyEmailSettingsView(viewModel: SettingsViewModel(authService: AuthService()))
    }
}

