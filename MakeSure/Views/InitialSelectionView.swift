//
//  AuthenticationSelectionView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI

struct InitialSelectionView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    @ObservedObject var loginViewModel: LoginViewModel
    
    @State private var showSignInSelectionView = false
    
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
                Spacer(minLength: 90)
            } else {
                Spacer(minLength: 90)
            }
            
            VStack(alignment: .trailing) {
                Text("Be confident in your")
                    .font(.interRegularFont(size: 23))
                    .foregroundColor(.white)
                Text("pleasure")
                    .font(.interRegularFont(size: 23))
                    .foregroundColor(.white)
            }
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
        .background(
            Image("AuthenticationSelectionImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
        )
        .edgesIgnoringSafeArea(.all)
    }
        
    @ViewBuilder
    func mainInitialView() -> some View {
        VStack {
            VStack {
                NavigationLink(destination: RegistrationWrapperView(viewModel: registrationViewModel)) {
                    Text("GET STARTED")
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
                    Text("SIGN IN")
                        .font(.rubicBoldFont(size: 20))
                        .padding()
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                }
            }
            
            VStack(alignment: .center) {
                Text("By Creating Account you Accept ")
                    .foregroundColor(.white)
                    .font(.interExtraLightFont(size: 12))
                
                HStack {
                    Text("Terms of Use")
                        .font(.interExtraLightFont(size: 12))
                        .underline()
                        .foregroundColor(.white)
                        .onTapGesture {
                            loginViewModel.openTermsOfUse()
                        }
                    
                    Text("and")
                        .foregroundColor(.white)
                        .font(.interExtraLightFont(size: 12))
                    
                    Text("Privacy Policy")
                        .font(.interExtraLightFont(size: 12))
                        .underline()
                        .foregroundColor(.white)
                        .onTapGesture {
                            loginViewModel.openPrivacyPolicy()
                        }
                }
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    func signInInitialView() -> some View {
        VStack(spacing: 16) {
            NavigationLink(destination: AppleSignInView(viewModel: loginViewModel)) {
                HStack {
                    Image(systemName: "applelogo")
                        .foregroundColor(.white)
                        .font(.rubicBoldFont(size: 20))
                    Spacer()
                    
                    Text("SIGN IN WITH APPLE")
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
                    
                    Text("SIGN IN WITH PHONE NUMBER")
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
                Text("Trouble signing in?")
                    .font(.rubicRegularFont(size: 17))
                    .padding()
                    .foregroundColor(.white)
            }
        }
        .padding(20)
    }
    
}

struct AuthenticationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InitialSelectionView(registrationViewModel: RegistrationViewModel(authService: AuthService()), loginViewModel: LoginViewModel(authService: AuthService()))
    }
}
