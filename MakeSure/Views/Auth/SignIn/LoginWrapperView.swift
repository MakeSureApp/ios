//
//  LoginWrapperView.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import SwiftUI

struct LoginWrapperView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            HStack {
                BackButtonView(color: CustomColors.darkBlue) {
                    viewModel.moveToPreviousStep()
                }
                Spacer()
            }
            .padding()
            
            switch viewModel.currentStep {
            case .initial:
                let _ = self.onBackPressed()
            case .phoneNumber:
                NumberSignInView(viewModel: viewModel)
            case .code:
                CodeSignInView(viewModel: viewModel)
            case .final:
                let _ = self.authorizationCompleted()
            }
            
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.canProceedToNextStep) {
                viewModel.moveToNextStep()
            }
            .padding(.horizontal)
        }
    }
    
    func onBackPressed() {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.async {
            viewModel.resetAllData()
        }
    }
    
    func authorizationCompleted() {
        viewModel.completeAuthorization()
    }
}
