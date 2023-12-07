//
//  ChangePhoneNumber.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct EmailSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var isAnimating: Bool = false
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        VStack {
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
                TextField("enter_email_placeholder".localized.lowercased(), text: $viewModel.changingEmail)
                    .font(.rubicMediumFont(size: 20))
                    .foregroundStyle(CustomColors.darkBlue)
                    .tint(CustomColors.darkBlue)
                    .keyboardType(.emailAddress)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 2)
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        self.focusedField = .field
                    }
                    .onChange(of: viewModel.changingEmail) { newValue in
                        viewModel.handleEmailChange(to: newValue)
                    }
            }
            
            if viewModel.isCheckingEmail {
                RotatingShapesLoader(animate: $isAnimating, color: .black)
                    .frame(maxWidth: 60)
                    .onAppear {
                        isAnimating = true
                    }
                    .onDisappear {
                        isAnimating = false
                    }
                Spacer()
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
        .overlay {
            if viewModel.isLoading {
                RotatingShapesLoader(animate: $isAnimating, color: .black)
                    .frame(maxWidth: 80)
                    .onAppear {
                        isAnimating = true
                    }
                    .onDisappear {
                        isAnimating = false
                    }
            }
        }
    }
}

struct EmailSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EmailSettingsView()
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel(), authService: AuthService()))
    }
}
