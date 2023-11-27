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
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            if viewModel.phoneCurrentStep != .congratulations {
                HStack {
                    BackButtonView(color: .black) {
                        viewModel.phoneMoveToPreviousStep()
                    }
                    Spacer()
                }
                .padding()
            }
            
            switch viewModel.phoneCurrentStep {
            case .initial:
                let _ = self.onBackPressed()
            case .phoneNumber:
                NumberSettingsView()
                    .environmentObject(viewModel)
            case .code:
                CodeSettingsView()
                    .environmentObject(viewModel)
            case .congratulations:
                CongratulationsNumberSettingsView()
                    .environmentObject(viewModel)
            case .final:
                let _ = self.updatingCompleted()
            }
            
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.phoneCanProceedToNextStep) {
                viewModel.phoneMoveToNextStep()
            }
        }
        .background(.white)
    }
    
    func onBackPressed() {
        presentationMode.wrappedValue.dismiss()
        viewModel.phoneResetAllData()
    }
    
    func updatingCompleted() {
        presentationMode.wrappedValue.dismiss()
        viewModel.phoneResetAllData()
    }
    
}
