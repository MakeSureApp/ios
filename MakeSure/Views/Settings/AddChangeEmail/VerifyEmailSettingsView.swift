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
                Text("email_sent_message".localized)
                    .font(.rubicBoldFont(size: 44))
                    .fontWeight(.bold)
                
                Text("click_to_verify_email".localized)
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

