//
//  PositiveTestContactsSelectionView.swift
//  MakeSure
//
//  Created by Macbook Pro on 18.09.2023.
//

import SwiftUI

struct PositiveTestContactsSelectionView: View {
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @EnvironmentObject var viewModel: ScannerViewModel
    @State private var isAnimatingForHighRish: Bool = false
    @State private var isAnimatingForPossibleRish: Bool = false
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Text("notify_partners".localized)
                    .font(.montserratBoldFont(size: 28))
                    .foregroundStyle(CustomColors.darkBlue)
                    .padding()
                Spacer()
                Button(action: {
                    showAlert.toggle()
                }, label: {
                    Text("exit".localized)
                        .font(.montserratRegularFont(size: 14))
                        .foregroundStyle(.gray)
                        .padding()
                })
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("you_sure_do_not_notify".localized),
                        message: Text("notify_warning_message".localized),
                        primaryButton: .destructive(Text("accept_responsibility".localized)) {
                            withAnimation {
                                viewModel.resetData(showScanner: false)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("high_risk_infection_users".localized)
                    .font(.montserratRegularFont(size: 14))
                    .foregroundStyle(CustomColors.darkBlue)
                    .padding()
                Text("anonymous_warnings_message".localized)
                    .font(.montserratRegularFont(size: 14))
                    .foregroundStyle(CustomColors.darkBlue)
                    .padding()
            }
            if viewModel.isLoadingHighRiskUsers || viewModel.isLoadingPossibleRiskUsers {
                RotatingShapesLoader(animate: $isAnimatingForHighRish, color: .black)
                    .frame(maxWidth: 100)
                    .padding(.top, 50)
                    .onAppear {
                        isAnimatingForHighRish = true
                    }
                    .onDisappear {
                        isAnimatingForHighRish = false
                    }
            } else if viewModel.hasLoadedHighRiskUsers, viewModel.hasLoadedPossibleRiskUsers {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.riskOfInfectionUsers) { user in
                            SelectContactItemView(image: viewModel.riskOfInfectionUsersImages[user.user.id], date: contactsViewModel.getLastDateWith(contact: user.user), contact: user.user, isEnabled: !user.isHighRisk, selectedContactIds: $viewModel.selectedForNotificationContactsIds)
                                .task {
                                    await viewModel.loadImage(user: user.user, for: .riskOfInfectionUser)
                                }
                        }
                    }
                    .padding(.vertical, 6)
                    .background(Color(red: 230/255, green: 230/255, blue: 230/255))
                    .cornerRadius(16)
                    .padding(.horizontal, 6)
                }
            } else {
                Spacer()
                    .frame(height: 30)
            }
            
           
            Spacer()
            RoundedGradientButton(text: "notify".localized.uppercased(), isEnabled: viewModel.hasLoadedHighRiskUsers && viewModel.hasLoadedPossibleRiskUsers) {
                Task {
                    await viewModel.sendNotificationsAboutRiskOfInfection(forHighRiskUsers: false)
                }
                withAnimation {
                    viewModel.resetData(showScanner: false)
                }
            }
            .padding(.horizontal, 30)
        }
        .background(.white)

//
//        if contactsViewModel.isAddingDate {
//            RotatingShapesLoader(animate: $isAnimating, color: .black)
//                .frame(maxWidth: 80)
//                .onAppear {
//                    isAnimating = true
//                }
//                .onDisappear {
//                    isAnimating = false
//                }
//                .zIndex(1)
//        }
    }
}

struct PositiveTestContactsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestContactsSelectionView()
            .environmentObject(ContactsViewModel())
            .environmentObject(ScannerViewModel())
    }
}
