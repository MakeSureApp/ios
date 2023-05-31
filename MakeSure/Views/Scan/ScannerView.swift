//
//  ScannerView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI
import CodeScanner

struct ScannerView: View {
    @EnvironmentObject var viewModel: ScannerViewModel
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                if let code = viewModel.scannedCode {
                    VStack {
                        if viewModel.isLoading {
                            RotatingShapesLoader(animate: $isAnimating)
                                .frame(maxWidth: 100)
                                .padding(.top, 50)
                                .onAppear {
                                    isAnimating = true
                                }
                                .onDisappear {
                                    isAnimating = false
                                }
                        } else if viewModel.hasLoaded, let user = viewModel.user {
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
                                    .font(.poppinsBoldFont(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding(.top, 20)
                                Spacer()
                                if contactsViewModel.checkIfUserAlreadyIsContact(id: user.id) {
                                    //add localization
                                    Text("You already have this contact")
                                        .font(.rubicBoldFont(size: 15))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                } else if contactsViewModel.userId == user.id {
                                    Text("It's you!")
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
                                           await  contactsViewModel.addUserToContacts(user: user)
                                        }
                                        viewModel.scannedCode = nil
                                    } label: {
                                        //add localization
                                        Text("Add to contacts".uppercased())
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
                                    mainViewModel.currentTab = .home
                                    viewModel.resetData()
                                } label: {
                                    Text("Dismiss".uppercased())
                                        .font(.rubicBoldFont(size: 15))
                                        .foregroundColor(.white)
                                        .padding(.vertical)
                                }
                            }
                            .padding()
                            .onAppear {
                                viewModel.isShowUser = true
                            }
                            
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.poppinsBoldFont(size: 20))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }.task {
                        await viewModel.searchUser(id: code)
                    }
                } else if contactsViewModel.isAddingUserToContacts {
                    RotatingShapesLoader(animate: $isAnimating)
                        .frame(maxWidth: 100)
                        .padding(.top, 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                } else if contactsViewModel.hasAddedUserToContacts, let user = viewModel.user {
                    VStack {
                        Spacer()
                        Spacer()
                        Text(user.name)
                            .font(.poppinsBoldFont(size: 30))
                            .foregroundColor(.white)
                            .padding()
                        Text("successfuly added to contacts") // add localization
                            .font(.poppinsBoldFont(size: 20))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Button {
                            mainViewModel.currentTab = .home
                            viewModel.resetData()
                        } label: {
                            Text("OK".uppercased())
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }
                    }
                    .padding()
                } else if !viewModel.isShowUser {
                    Spacer()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    self.viewModel.isPresentingScanner = true
                                }
                            }
                        }
                }
            }
            .padding(.bottom, 40)
        }
        .task {
            if contactsViewModel.contactsM.isEmpty {
                await contactsViewModel.fetchContacts()
            }
        }
        .sheet(isPresented: $viewModel.isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr]) { response in
                if case let .success(result) = response {
                    print(result)
                    viewModel.scannedCode = result.string
                    viewModel.isPresentingScanner = false
                }
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
            .environmentObject(ScannerViewModel())
            .environmentObject(ContactsViewModel())
            .environmentObject(MainViewModel(authService: AuthService()))
    }
}
