//
//  ConnectAppleSignUpView.swift
//  MakeSure
//
//  Created by Macbook Pro on 24.08.2023.
//

import SwiftUI

struct LinkAppleSignUpView: View {
    
    @ObservedObject var viewModel: RegistrationViewModel
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                Text("link_apple".localized)
                    .font(.rubicBoldFont(size: 32))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(CustomColors.darkBlue)
                    .padding(.bottom, 8)
                Text("link_apple_description".localized)
                    .font(.interLightFont(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(CustomColors.darkGray)
            }
            Spacer()
            if viewModel.appleIdLinked {
                withAnimation {
                    Text("apple_linked_successfully".localized)
                        .font(.rubicBoldFont(size: 30))
                        .foregroundColor(Color.secondGreen)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            } else {
                Button {
                    viewModel.registerWithApple()
                } label: {
                    VStack {
                        Spacer()
                        Image(systemName: "applelogo")
                            .resizable()
                            .frame(width: 50, height: 60)
                            .foregroundColor(Color.gradientDarkBlue)
                        //                        .font(.rubicBoldFont(size: 30))
                        Spacer()
                        Text("link_apple_short".localized.uppercased())
                            .font(.rubicBoldFont(size: 30))
                            .foregroundColor(Color.gradientDarkBlue)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(RoundedRectangle(cornerRadius: 50)
                        .stroke(CustomColors.secondGradient, lineWidth: 3))
                }
                .padding(.horizontal, 50)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 30)
        .overlay {
            if viewModel.isLoggingInWithApple || viewModel.isLoadingUser {
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
            if let error = viewModel.linkingError {
                withAnimation {
                    Text(error == .isAlreadyRegistered ? "apple_already_linked".localized : "error_occurred".localized)
                        .padding(20)
                        .foregroundColor(.red)
                        .font(.montserratMediumFont(size: 20))
                        .background(.black.opacity(0.9))
                        .cornerRadius(16)
                }
            }
        }
    }
}

struct ConnectAppleSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        LinkAppleSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
