//
//  RegistrationWrapperView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct RegistrationWrapperView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: RegistrationViewModel
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.currentStep != .final {
                // ProgressBar
                if viewModel.isProgresBarShow {
                    RegistrationProgressBarView(progress: viewModel.currentProgressBarStep.rawValue, countParts: RegistrationProgressBarSteps.allCases.count)
                } else {
                    Spacer()
                        .frame(height: 8)
                }
                
                HStack {
                    BackButtonView(color: .black) {
                        viewModel.moveToPreviousStep()
                    }
                    Spacer()
                    if viewModel.isSkipButtonShow {
                        Button {
                            viewModel.skipPage()
                        } label: {
                            Text("skip_button".localized)
                                .font(.rubicRegularFont(size: 24))
                                .foregroundColor(.gray)
                        }
                        
                    }
                }
                .padding()
                .padding(.horizontal, 8)
            }
            
            switch viewModel.currentStep {
            case .initial:
                let _ = self.onBackPressed()
            case .phoneNumber:
                NumberSignUpView(viewModel: viewModel)
            case .code:
                CodeSignUpView(viewModel: viewModel)
            case .email:
                EmailSignUpView(viewModel: viewModel)
                // case .verifyEmail:
                //VerifyEmailSignUpView(viewModel: viewModel)
            case .firstName:
                NameSignUpView(viewModel: viewModel)
            case .birthday:
                BirthdaySignUpView(viewModel: viewModel)
                //            case .gender:
                //                GenderSignUpView(viewModel: viewModel)
                //            case .profilePhoto:
                //                AddPhotoSignUpView(viewModel: viewModel)
            case .linkApple:
                LinkAppleSignUpView(viewModel: viewModel)
            case .agreement:
                TermsOfUseSignUpView(viewModel: viewModel)
            case .congratulations:
                CongratulationSignUpView(viewModel: viewModel)
            case .final:
                VStack {
                    Spacer()
                    if viewModel.isLoading {
                        RotatingShapesLoader(animate: $isAnimating, color: .black)
                            .frame(maxWidth: 120)
                            .onAppear {
                                isAnimating = true
                            }
                            .onDisappear {
                                isAnimating = false
                            }
                    }
                    Spacer()
                }.task {
                    await viewModel.completeRegistration()
                }
            }
            
            if viewModel.currentStep != .final {
                // Continue button
                RoundedGradientButton(text: viewModel.currentStep == .agreement ? "agree_button".localized.uppercased() : "continue_button".localized.uppercased(), isEnabled: viewModel.canProceedToNextStep) {
                    viewModel.moveToNextStep()
                }
                .padding(.horizontal)
            }
        }
    }
    
    func onBackPressed() {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.async {
            viewModel.resetAllData()
        }
    }
}
