//
//  CongratulationsNumberSettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import SwiftUI

struct CongratulationsNumberSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            // Title
            Text("new_number_linked_message".localized)
                .font(.rubicBoldFont(size: 24))
                .foregroundStyle(CustomColors.darkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            HStack {
                Text(viewModel.phoneNumber)
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

struct CongratulationsNumberSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsNumberSettingsView()
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel(), authService: AuthService()))
    }
}
