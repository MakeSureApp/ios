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
    
    var body: some View {
        VStack {
            HStack {
                Text("high_risk_infection_message".localized)
                    .font(.montserratBoldFont(size: 28))
                    .padding()
                Spacer()
            }
            HStack {
                Text("anonymous_warnings_message".localized)
                    .font(.montserratRegularFont(size: 18))
                    .padding()
                Spacer()
            }
            if viewModel.isLoadingHighRiskUsers {
                RotatingShapesLoader(animate: $isAnimatingForHighRish, color: .black)
                    .frame(maxWidth: 100)
                    .padding(.top, 50)
                    .onAppear {
                        isAnimatingForHighRish = true
                    }
                    .onDisappear {
                        isAnimatingForHighRish = false
                    }
            } else if viewModel.hasLoadedHighRiskUsers {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.highRiskOfInfectionContacts) { contact in
                            ContactItemView(image: viewModel.highRiskUsersImages[contact.id], date: contactsViewModel.getLastDateWith(contact: contact),
                                            contact: contact)
                            .task {
                                await viewModel.loadImage(user: contact, for: .highRiskUser)
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
    
            HStack {
                Text("possible_risk_message".localized)
                    .font(.montserratBoldFont(size: 28))
                    .padding()
                Spacer()
            }
            HStack {
                Text("select_partners_message".localized)
                    .font(.montserratRegularFont(size: 18))
                    .padding()
                Spacer()
            }
            
            if viewModel.isLoadingPossibleRiskUsers {
                RotatingShapesLoader(animate: $isAnimatingForPossibleRish, color: .black)
                    .frame(maxWidth: 100)
                    .padding(.top, 50)
                    .onAppear {
                        isAnimatingForPossibleRish = true
                    }
                    .onDisappear {
                        isAnimatingForPossibleRish = false
                    }
            } else if viewModel.hasLoadedPossibleRiskUsers {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.possibleRiskOfInfectionContacts) { contact in
                            SelectContactItemView(image: viewModel.possibleRiskUsersImages[contact.id], date: contactsViewModel.getLastDateWith(contact: contact), contact: contact, selectedContactIds: $viewModel.selectedForNotificationContactsIds)
                                .task {
                                    await viewModel.loadImage(user: contact, for: .possibleRiskUser)
                                }
                        }
                    }
                }
            } else {
                Spacer()
                    .frame(height: 30)
            }
        }
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
    }
}
