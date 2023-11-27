//
//  SearcedUserView.swift
//  MakeSure
//
//  Created by Macbook Pro on 21.06.2023.
//

import SwiftUI

struct SearchedUserView: View {
    @EnvironmentObject var viewModel: ScannerViewModel
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @Binding var isShowView: Bool
    var userId: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
              if viewModel.hasLoaded, let user = viewModel.searchedUser {
                    VStack {
                        Spacer()
                            .frame(height: 40)
                        if let image = viewModel.userImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 220, height: 220)
                                .clipShape(Circle())
                                .shadow(color: .white, radius: 50)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 220, height: 220)
                                .clipShape(Circle())
                                .shadow(color: .white, radius: 30)
                        }
                        Text(user.name)
                            .font(.montserratBoldFont(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .padding(.top, 20)
                        Spacer()
                        if contactsViewModel.checkIfUserBlocked(id: user.id) {
                            Text("contact_blocked".localized)
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .padding()
                                .frame(maxWidth: .infinity)
                            Button {
                                Task {
                                    await contactsViewModel.unlockUser(user.id)
                                }
                                viewModel.scannedCode = nil
                                isShowView = false
                            } label: {
                                //add localization
                                Text("unblock".localized.uppercased())
                                    .font(.rubicBoldFont(size: 15))
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.gradientDarkBlue2)
                                    )
                            }
                        }
                        else if contactsViewModel.checkIfUserAlreadyIsContact(id: user.id) {
                            //add localization
                            Text("contact_already_exists".localized)
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .padding()
                                .frame(maxWidth: .infinity)
                            Spacer()
                        } else if contactsViewModel.userId == user.id {
                            Text("it_is_you".localized)
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .padding()
                                .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            Button {
                                Task {
                                    await contactsViewModel.addUserToContacts(user: user)
                                }
                                viewModel.scannedCode = nil
                                isShowView = false
                            } label: {
                                //add localization
                                Text("add_to_contacts".localized.uppercased())
                                    .font(.rubicBoldFont(size: 15))
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.gradientDarkBlue2)
                                    )
                            }
                        }
                        Button {
                            onDismiss()
                        } label: {
                            Text("dismiss_button".localized.uppercased())
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }
                    }
                    .padding()
                    .onAppear {
                        viewModel.isShowUser = true
                    }
                    
                } 
            }.task {
                await viewModel.searchGlobalUser(id: userId)
            }
        }
    }
}

//struct SearcedUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchedUserView(userId: "", onDismiss: {})
//            .environmentObject(ScannerViewModel())
//            .environmentObject(ContactsViewModel())
//    }
//}
