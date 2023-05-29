//
//  SignInSelectionView.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import SwiftUI

struct SignInSelectionView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            HStack {
                BackButtonView(color: .white) {
                    isVisible = false
                }
                .zIndex(1)
                Spacer()
            }
            .padding()
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            Spacer(minLength: 60)
            
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
            
            // Buttons
            VStack(spacing: 16) {
                NavigationLink(destination: AppleSignInView(viewModel: loginViewModel)) {
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
                }
                
                Button {
                    isVisible = false
                } label: {
                    Text("trouble_signing_in".localized)
                        .font(.rubicRegularFont(size: 17))
                        .padding()
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 40)
            Spacer(minLength: 150)
        }
        .background(
            Image("AuthenticationSelectionImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fit)
        )
        .edgesIgnoringSafeArea(.all)
    }
}

//struct SignInSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInSelectionView(loginViewModel: LoginViewModel(authService: AuthService()), showSignInSelectionView: <#Binding<Bool>#>)
//    }
//}




