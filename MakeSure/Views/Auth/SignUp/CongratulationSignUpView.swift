//
//  CongratulationView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct CongratulationSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            // Title
            Text("Congratulations!")
                .font(.rubicMediumFont(size: 40))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top, 30)

            Spacer()
        }
    }
}
