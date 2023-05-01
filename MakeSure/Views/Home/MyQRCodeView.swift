//
//  MyQRCodeView.swift
//  MakeSure
//
//  Created by andreydem on 5/1/23.
//

import SwiftUI

struct MyQRCodeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button {
                        viewModel.showMyQRCode = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    ShareLink(item: viewModel.name) {
                        Label("", systemImage: "square.and.arrow.up")
                            .frame(width: 18, height: 24)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: 40, height: 40))
                        .frame(maxWidth: 310, maxHeight: 340)
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 20)
                        .padding()
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 106, height: 106)
                            .padding(.bottom, 380)
                            .zIndex(1)
                    }
                    VStack {
                        Image("mockqrcode")
                            .resizable()
                            .frame(width: 240, height: 220)
                            .padding([.leading, .trailing, .top])
                        Text(viewModel.name.uppercased())
                            .font(.rubicBoldFont(size: 22))
                            .foregroundColor(Color(red: 114/255, green: 146/255, blue: 174/255))
                    }
                }
                Spacer()
            }
            .padding(20)
        }
    }
}

struct MyQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        MyQRCodeView(viewModel: HomeViewModel())
    }
}
