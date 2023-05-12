//
//  BlacklistView.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct BlacklistView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ContactsViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var isAnimating: Bool = false
    @State private var isAnimatingImage: Bool = false
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding([.top, .leading], 16)
                .padding(.bottom, -12)
                
                if viewModel.isLoadingBlacklist {
                    Spacer()
                    RotatingShapesLoader(animate: $isAnimating)
                        .frame(maxWidth: 100)
                        .padding(.top, 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                    Spacer()
                } else if viewModel.hasLoadedBlacklist {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            HStack {
                                Text("Blacklist")
                                    .font(.poppinsLightFont(size: 35))
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                            }
                            Text("Описание про то, что могут и не могут пользователи из черного списка")
                                .font(.poppinsLightFont(size: 16))
                                .foregroundColor(.white)
                            
                            ForEach(viewModel.blockedUsers, id: \.self) { user in
                                HStack {
                                        if let image = viewModel.blacklistImages[user.id] {
                                            Image(uiImage: image)
                                                .resizable()
                                                .frame(width: 63, height: 63)
                                                .clipShape(Circle())
                                                .padding(.trailing, 10)
                                                .shadow(radius: 10)
                                        } else if user.photoUrl == nil {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.white)
                                                .frame(width: 63, height: 63)
                                                .clipShape(Circle())
                                                .padding(.trailing, 10)
                                        } else {
                                            Circle()
                                                .foregroundColor(.gradientDarkBlue)
                                                .frame(width: 63, height: 63)
                                                .overlay(
                                                    RotatingShapesLoader(animate: $isAnimatingImage)
                                                        .frame(maxWidth: 25)
                                                        .onAppear {
                                                            isAnimatingImage = true
                                                        }
                                                        .onDisappear {
                                                            isAnimatingImage = false
                                                        }
                                                )
                                        }
                                        Text(user.name)
                                            .font(.poppinsBoldFont(size: 16))
                                            .foregroundColor(.white)
                                    Spacer()
                                    Button(action: {
                                            Task {
                                                await viewModel.unlockUser(user.id, contacts: homeViewModel.user?.contacts)
                                            }
                                    }) {
                                        Text("unlock")
                                            .font(.poppinsRegularFont(size: 14))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(red: 247/255, green: 213/255, blue: 1))
                                            .cornerRadius(5)
                                    }
                                }
                                .padding(.vertical, -8)
                                .task {
                                    await viewModel.loadImage(user: user, for: .blacklist)
                                }
                            }
                        }
                        .padding([.leading, .trailing], 30)
                    }
                } else {
                    Text("Blacklist is empty")
                        .font(.poppinsBoldFont(size: 18))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .task {
            await viewModel.fetchBlacklist()
        }
    }
}

struct BlacklistView_Previews: PreviewProvider {
    static var previews: some View {
        BlacklistView(viewModel: ContactsViewModel(), homeViewModel: HomeViewModel())
    }
}
