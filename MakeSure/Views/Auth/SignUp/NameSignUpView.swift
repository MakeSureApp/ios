//
//  FirstNameView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct NameSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text("My first \nname is")
                    .font(.rubicBoldFont(size: 44))
                    .fontWeight(.bold)
                
                Text("Pay attention: you will be able to change your name only by contacting the support service.")
                    .font(.interLightFont(size: 14))
                    .foregroundColor(CustomColors.darkGray)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            // First name input
            CustomUnderlinedView {
                TextField("First name", text: $viewModel.firstName)
                    .font(.interRegularFont(size: 23))
                    .foregroundColor(.black)
                    .padding(4)
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        self.focusedField = .field
                    }
                    .onChange(of: viewModel.firstName) { newValue in
                        viewModel.validateName(newValue)
                    }
            }
            .padding(.horizontal, 22)
            
            Spacer()
        }
    }
}

struct NameSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NameSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
