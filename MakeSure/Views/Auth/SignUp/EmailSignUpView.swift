//
//  EmailView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct EmailSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        VStack {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("enter_email".localized)
                    .font(.rubicBoldFont(size: 32))
                    .foregroundStyle(CustomColors.darkBlue)
                    .fontWeight(.bold)
                
                Text("enter_email_continuation".localized)
                    .font(.interLightFont(size: 14))
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 40)
            
            // Email input
            CustomUnderlinedView {
                TextField("enter_email_placeholder".localized.lowercased(), text: $viewModel.email)
                    .font(.rubicMediumFont(size: 20))
                    .foregroundStyle(CustomColors.darkBlue)
                    .tint(CustomColors.darkBlue)
                    .keyboardType(.emailAddress)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 2)
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        self.focusedField = .field
                    }
                    .onChange(of: viewModel.email) { newValue in
                        viewModel.validateEmail()
                    }
            }
            
            HStack {
                Text("verify_email_prompt".localized)
                    .font(.interLightFont(size: 14))
                    .foregroundStyle(.gray)
                    .padding(.vertical, 12)
                Spacer()
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
}

struct EmailSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
