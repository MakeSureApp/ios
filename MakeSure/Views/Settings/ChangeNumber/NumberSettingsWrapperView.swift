//
//  NumberSettingsWrapperView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI

struct NumberSettingsWrapperView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                BackButtonView(color: .black) {
                    viewModel.phoneMoveToPreviousStep()
                }
                Spacer()
            }
            .padding()
            
            switch viewModel.phoneCurrentStep {
            case .initial:
                let _ = self.onBackPressed()
            case .phoneNumber:
                NumberSettingsView(viewModel: viewModel)
            case .code:
                CodeSettingsView(viewModel: viewModel)
            case .congratulations:
                CongratulationsNumberSettingsView(viewModel: viewModel)
            case .final:
                let _ = self.authorizationCompleted()
            }
            
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.phoneCanProceedToNextStep) {
                viewModel.phoneMoveToNextStep()
            }
        }
    }
    
    func onBackPressed() {
        presentationMode.wrappedValue.dismiss()
        viewModel.phoneResetAllData()
    }
    
    func authorizationCompleted() {
        presentationMode.wrappedValue.dismiss()
        viewModel.completeChangingPhoneNumber()
    }
    
}
