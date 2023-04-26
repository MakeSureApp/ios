//
//  CongratulationsEmailSettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import SwiftUI

struct CongratulationsEmailSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            // Title
            Text("Congratulations, your new email is \nlinked!")
                .font(.rubicBoldFont(size: 34))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top, 30)

            HStack {
                Text(viewModel.emailAddress)
                    .font(.rubicRegularFont(size: 26))
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}

struct CongratulationsEmailSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsEmailSettingsView(viewModel: SettingsViewModel(authService: AuthService()))
    }
}
