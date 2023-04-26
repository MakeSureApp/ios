//
//  CongratulationsNumberSettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import SwiftUI

struct CongratulationsNumberSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            // Title
            Text("Congratulations, your new number is \nlinked!")
                .font(.rubicBoldFont(size: 34))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top, 30)

            HStack {
                Text(viewModel.phoneNumber)
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

struct CongratulationsNumberSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsNumberSettingsView(viewModel: SettingsViewModel(authService: AuthService()))
    }
}
