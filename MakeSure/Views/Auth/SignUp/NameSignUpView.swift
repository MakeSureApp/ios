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
                Text("whats_your_name".localized)
                    .font(.rubicBoldFont(size: 32))
                    .foregroundStyle(CustomColors.darkBlue)
                
                Text("name_change_warning".localized)
                    .font(.interLightFont(size: 14))
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 30)

            CustomUnderlinedView {
                TextField("first_name".localized.lowercased(), text: $viewModel.firstName)
                    .font(.rubicMediumFont(size: 20))
                    .foregroundStyle(CustomColors.darkBlue)
                    .tint(CustomColors.darkBlue)
                    .padding(4)
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        self.focusedField = .field
                    }
                    .onChange(of: viewModel.firstName) { newValue in
                        viewModel.validateName()
                    }
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

struct NameSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NameSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
