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
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            if viewModel.emailCurrentStep != .congratulations {
                HStack {
                    BackButtonView(color: CustomColors.darkBlue) {
                        viewModel.emailMoveToPreviousStep()
                    }
                    Spacer()
                }
                .padding()
            }
            
            switch viewModel.emailCurrentStep {
            case .initial:
                let _ = self.onBackPressed()
            case .email:
                EmailSettingsView()
                    .environmentObject(viewModel)
//            case .verifyEmail:
//                VerifyEmailSettingsView()
//                    .environmentObject(viewModel)
            case .congratulations:
                CongratulationsEmailSettingsView()
                    .environmentObject(viewModel)
            case .final:
                let _ = self.updatingCompleted()
            }
            
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.emailCanProceedToNextStep) {
                viewModel.emailMoveToNextStep()
            }
            .padding(.horizontal, 30)
        }
        .background(.white)
    }
    
    func onBackPressed() {
        presentationMode.wrappedValue.dismiss()
        viewModel.emailResetAllData()
    }
    
    func updatingCompleted() {
        presentationMode.wrappedValue.dismiss()
        viewModel.emailResetAllData()
    }
}
