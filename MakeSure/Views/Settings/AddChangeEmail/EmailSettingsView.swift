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
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("whats_your_email".localized)
                    .font(.rubicBoldFont(size: 44))
                    .minimumScaleFactor(0.5)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.interLightFont(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.red)
                        .padding()
                        .padding(.top, 20)
                } else {
                    Text("verify_email".localized)
                        .font(.interLightFont(size: 14))
                        .foregroundColor(CustomColors.darkGray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.bottom, 40)
            
            // Email input
            CustomUnderlinedView {
                TextField("enter_email_placeholder".localized, text: $viewModel.changingEmail)
                    .font(.interRegularFont(size: 23))
                    .foregroundColor(.black)
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
            .padding(.horizontal, 30)
            
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
            
            Spacer()
        }
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
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel()))
    }
}
