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
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.isSendingNotifications {
                Spacer()
                HStack {
                    Spacer()
                    RotatingShapesLoader(animate: $isAnimating, color: .black)
                        .frame(maxWidth: 100)
                        .padding(.top, 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                    Spacer()
                }
                Spacer()
            } else {
                Spacer()
                switch viewModel.notificationsCurrentStep {
                case .warning:
                    PositiveTestWarningView()
                        .environmentObject(viewModel)
                case .tips:
                    PositiveTestTipsView()
                        .environmentObject(viewModel)
                case .selection:
                    PositiveTestContactsSelectionView()
                        .environmentObject(viewModel)
                        .environmentObject(contactsViewModel)
                case .send_to_all:
                    PositiveTestSendNotificationsView()
                        .environmentObject(viewModel)
                case .visit_doctor:
                    PositiveTestVisitDoctorView()
                        .environmentObject(viewModel)
                case .final:
                    let _ = setupCompleted()
                }
                Spacer()
                RoundedGradientButton(text: viewModel.notificationBtnText.uppercased(), isEnabled: true) {
                    viewModel.notificationsMoveToNextStep()
                }
                if viewModel.notificationsCurrentStep == .send_to_all {
                    Button(action: {
                        viewModel.notificationsMoveToPreviousStep()
                    }) {
                        Text("go_back_button".localized.uppercased())
                            .font(.rubicBoldFont(size: 21))
                            .frame(maxWidth: .infinity)
                            .padding(4)
                            .overlay {
                                (CustomColors.secondGradient)
                                    .mask(
                                        Text("go_back_button".localized.uppercased())
                                            .font(.rubicBoldFont(size: 21))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                    )
                            }
                    }
                }
            }
        }
        .background(.white)
    }
    
    func setupCompleted() {
        presentationMode.wrappedValue.dismiss()
        viewModel.notificationsResetData()
    }
}

struct SendingNotificationsWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestNotificationsWrapperView()
            .environmentObject(ScannerViewModel())
            .environmentObject(ContactsViewModel())
    }
}
