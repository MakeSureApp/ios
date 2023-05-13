//
//  EmailSettingsWrapperView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI

struct EmailSettingsWrapperView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                BackButtonView(color: .black) {
                    viewModel.emailMoveToPreviousStep()
                }
                Spacer()
            }
            .padding()
            
            switch viewModel.emailCurrentStep {
            case .initial:
                let _ = self.onBackPressed()
            case .email:
                EmailSettingsView(viewModel: viewModel)
            case .verifyEmail:
                VerifyEmailSettingsView(viewModel: viewModel)
            case .congratulations:
                CongratulationsEmailSettingsView(viewModel: viewModel)
            case .final:
                let _ = self.authorizationCompleted()
            }
            
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.emailCanProceedToNextStep) {
                viewModel.emailMoveToNextStep()
            }
        }
    }
    
    func onBackPressed() {
        presentationMode.wrappedValue.dismiss()
        viewModel.emailResetAllData()
    }
    
    func authorizationCompleted() {
        presentationMode.wrappedValue.dismiss()
        viewModel.completeChangingEmail()
    }
}
