//
//  GenderView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct GenderSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            // Title
            Text("gender_prompt".localized)
                .font(.rubicBoldFont(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 30)

            // Gender buttons
            VStack(spacing: 24) {
                Button(action: {
                    viewModel.gender = .male
                }) {
                    Text("gender_male".localized.uppercased())
                        .font(.rubicBoldFont(size: 21))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(viewModel.gender == .male ? Color.gradientPurple : .gray, lineWidth: 2)
                        )
                        .overlay {
                            (viewModel.gender == .male ? CustomColors.secondGradient : CustomColors.grayGradient)
                                .mask(
                                    Text("gender_male".localized.uppercased())
                                        .font(.rubicBoldFont(size: 21))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                )
                        }
                }

                Button(action: {
                    viewModel.gender = .female
                }) {
                    Text("gender_female".localized.uppercased())
                        .font(.rubicBoldFont(size: 21))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(viewModel.gender == .female ? Color.gradientPurple : .gray, lineWidth: 2)
                        )
                        .overlay {
                            (viewModel.gender == .female ? CustomColors.secondGradient : CustomColors.grayGradient)
                                .mask(
                                    Text("gender_female".localized.uppercased())
                                        .font(.rubicBoldFont(size: 21))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                )
                        }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

struct GenderSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        GenderSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
