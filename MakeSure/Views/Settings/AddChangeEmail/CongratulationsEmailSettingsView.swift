//
//  CongratulationsEmailSettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import SwiftUI

struct CongratulationsEmailSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            // Title
            Text("new_email_linked_message".localized)
                .font(.rubicBoldFont(size: 24))
                .fontWeight(.bold)
                .foregroundStyle(CustomColors.darkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            HStack {
                Text(viewModel.emailAddress)
                    .font(.rubicRegularFont(size: 20))
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
        CongratulationsEmailSettingsView()
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel(), authService: AuthService()))
    }
}
