//
//  AuthenticationSelectionView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct InitialSelectionView: View {
    @ObservedObject private var registrationViewModel: RegistrationViewModel
    @ObservedObject private var loginViewModel: LoginViewModel
    @State private var showSignInSelectionView = false
    @State private var isAnimating: Bool = false
    
    init() {
        _registrationViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getRegistrationViewModel())
        _loginViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getLoginViewModel())
    }
    
    var body: some View {
        VStack {
            if showSignInSelectionView {
                HStack {
                    BackButtonView(color: .white) {
                        showSignInSelectionView = false
                    }
                    .zIndex(1)
                    Spacer()
                }
                .padding()
                .padding(.top, 30)
                Spacer()
            } else {
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                Text("confidence_message".localized)
                    .font(.interRegularFont(size: 23))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.white)
//                Text("pleasure")
//                    .font(.interRegularFont(size: 23))
//                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.leading, 40)
            
            VStack(alignment: .leading, spacing: -60) {
                Text("MAKE")
                    .font(.custom("BebasNeue", size: 169))
                    .foregroundColor(.white)
                Text("SURE")
                    .font(.custom("BebasNeue", size: 169))
                    .foregroundColor(.white)
            }
            .padding(.trailing)
            
            Spacer()
                .frame(height: 4)
            
            if showSignInSelectionView {
                signInInitialView()
            } else {
                mainInitialView()
            }
        }
        .frame(height: UIScreen.main.bounds.height)
        .background(
            Image("AuthenticationSelectionImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
        )
        .overlay {
            if loginViewModel.isLoggingInWithApple || loginViewModel.isLoadingUser {
                VStack {
                    RotatingShapesLoader(animate: $isAnimating)
                        .frame(maxWidth: 80)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                }
                .frame(width: 100, height: 100)
                .background(.black.opacity(0.8))
                .cornerRadius(16)
            }
            if let error = loginViewModel.loginError {
                withAnimation {
                    Text(error == .isNotRegistered ? "have_not_registered".localized : "error_occurred".localized)
                        .padding(20)
                        .foregroundColor(.red)
                        .font(.montserratMediumFont(size: 20))
                        .background(.black.opacity(0.9))
                        .cornerRadius(16)
                }
            }
        }
    }
        
    @ViewBuilder
    func mainInitialView() -> some View {
        VStack {
            VStack {
                NavigationLink(destination:
                                RegistrationWrapperView(viewModel: registrationViewModel)
                    .navigationBarHidden(true)) {
                    Text("get_started_button".localized.uppercased())
                        .font(.rubicBoldFont(size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundColor(.gradientDarkBlue)
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                }
                
                Button {
                    showSignInSelectionView.toggle()
                } label: {
                    Text("sign_in_button".localized.uppercased())
                        .font(.rubicBoldFont(size: 20))
                        .padding()
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                }
            }
            
            VStack(alignment: .center) {
                Text("accept_terms_and_privacy".localized + " ")
                    .foregroundColor(.white)
                    .font(.interExtraLightFont(size: 12))
                
                HStack {
                    Text("terms_of_use".localized)
                        .font(.interExtraLightFont(size: 12))
                        .underline()
                        .foregroundColor(.white)
                        .onTapGesture {
                            loginViewModel.openTermsOfUse()
                        }
                    
                    Text("and".localized)
                        .foregroundColor(.white)
                        .font(.interExtraLightFont(size: 12))
                    
                    Text("privacy_policy".localized)
                        .font(.interExtraLightFont(size: 12))
                        .underline()
                        .foregroundColor(.white)
                        .onTapGesture {
                            loginViewModel.openPrivacyPolicy()
                        }
                }
            }
            .padding(10)
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    func signInInitialView() -> some View {
        VStack(spacing: 16) {
            Button {
                loginViewModel.signInWithApple()
            } label: {
                HStack {
                    Image(systemName: "applelogo")
                        .foregroundColor(.white)
                        .font(.rubicBoldFont(size: 16))
                    Spacer()
                    
                    Text("sign_in_with_apple".localized.uppercased())
                        .font(.rubicBoldFont(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding(.horizontal, 10)
            }

            
            NavigationLink(destination: LoginWrapperView(viewModel: loginViewModel)) {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.white)
                        .font(.rubicBoldFont(size: 16))
                    Spacer()
                    
                    Text("sign_in_with_phone".localized.uppercased())
                        .font(.rubicBoldFont(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding(.horizontal, 10)
            }
            
            Button {
                
            } label: {
                Text("trouble_signing_in".localized)
                    .font(.rubicRegularFont(size: 17))
                    .padding()
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
    
}

struct AuthenticationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InitialSelectionView()
    }
}
