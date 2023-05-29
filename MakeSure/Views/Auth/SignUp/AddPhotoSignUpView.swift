//
//  AddPhotoView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct AddPhotoSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        VStack {
            // Title
            Text("add_photo".localized)
                .font(.rubicBoldFont(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            // Photo button
            Button(action: {
                // Open photo picker
                if !viewModel.photoAdded {
                    viewModel.requestAuthorization()
                }
            }) {
                if let image = viewModel.image {
                    Image(uiImage: image)
                    //Image("tastLandscapeImage")
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fit)
                        .cornerRadius(50)
                        .frame(maxWidth: .infinity)
                        .overlay(Group {
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(CustomColors.secondGradient, lineWidth: 3)
                            ZStack {
                                Button {
                                    viewModel.removeImage()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 53, height: 53)
                                }
                                .foregroundStyle(Color.gradientDarkBlue, .purple, .white)
                                .overlay {
                                    Circle()
                                        .stroke(CustomColors.secondGradient, lineWidth: 3)
                                }
                                .padding(.top, -12)
                                .padding(.trailing, -12)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        })
                } else {
                    VStack {
                        Spacer()
                        Image("camera_icon")
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/4, contentMode: .fit)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 50)
                        .stroke(CustomColors.secondGradient, lineWidth: 3))
                }
            }
            .padding()
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AddPhotoSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
