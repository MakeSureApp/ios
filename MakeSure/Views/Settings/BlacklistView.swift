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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        HStack {
                            Text("Blacklist")
                                .font(.poppinsLightFont(size: 35))
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }
                        Text("Описание про то, что могут и не могут пользователи из черноко списка")
                            .font(.poppinsLightFont(size: 16))
                            .foregroundColor(.white)
                        
                        ForEach(viewModel.blockedUsers, id: \.self) { user in
                            HStack {
                                Image(uiImage: user.image)
                                    .resizable()
                                    .frame(width: 63, height: 63)
                                    .padding(.trailing, 10)
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.poppinsBoldFont(size: 16))
                                        .foregroundColor(.white)
                                    Text("@(user.username)")
                                        .font(.poppinsLightFont(size: 12))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        viewModel.unlockUser(user)
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
                        }
                    }
                }
                .padding([.leading, .trailing], 30)
            }
        }
    }
}

struct BlacklistView_Previews: PreviewProvider {
    static var previews: some View {
        BlacklistView(viewModel: ContactsViewModel())
    }
}
