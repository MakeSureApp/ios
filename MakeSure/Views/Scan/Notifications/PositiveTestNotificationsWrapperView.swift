//
//  PositiveTestNotificationsWrapperView.swift
//  MakeSure
//
//  Created by Macbook Pro on 18.09.2023.
//

import SwiftUI

struct PositiveTestNotificationsWrapperView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewModel: ScannerViewModel
    
    var body: some View {
        VStack {
            if viewModel.emailCurrentStep != .congratulations {
                HStack {
                    BackButtonView(color: .black) {
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
        }
        .background(.white)
        .padding(4)
        .cornerRadius(12)
    }
}

struct SendingNotificationsWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestNotificationsWrapperView()
            .environmentObject(ScannerViewModel())
    }
}
