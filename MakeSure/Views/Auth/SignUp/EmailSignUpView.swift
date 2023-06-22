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
                Text("whats_your_email".localized)
                    .font(.rubicBoldFont(size: 44))
                    .fontWeight(.bold)
                
                Text("verify_email".localized)
                    .font(.interLightFont(size: 14))
                    .foregroundColor(CustomColors.darkGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.bottom, 40)
            
            // Email input
            CustomUnderlinedView {
                TextField("enter_email_placeholder".localized, text: $viewModel.email)
                    .font(.interRegularFont(size: 23))
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 2)
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        self.focusedField = .field
                    }
                    .onChange(of: viewModel.email) { newValue in
                        viewModel.validateEmail(newValue)
                    }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
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
