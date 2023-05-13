//
//  MyQRCodeView.swift
//  MakeSure
//
//  Created by andreydem on 5/1/23.
//

import SwiftUI
import QRCode

struct MyQRCodeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isAnimating = false
    
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
                    if viewModel.hasGeneratedQRCode {
                        ShareLink(item: viewModel.user?.name ?? "") {
                            Label("", systemImage: "square.and.arrow.up")
                                .frame(width: 18, height: 24)
                                .foregroundColor(.white)
                        }
                    }
                }
                if viewModel.isGeneratingQRCode {
                    Spacer()
                    RotatingShapesLoader(animate: $isAnimating, color: .white)
                        .frame(maxWidth: 100)
                        .padding(.top, 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                    Spacer()
                } else if viewModel.hasGeneratedQRCode {
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
                                .clipShape(Circle())
                                .padding(.bottom, 380)
                                .zIndex(1)
                        }
                        VStack {
                            if let text = viewModel.qrCodeText {
                                if let logoImage = UIImage(named: "qrcodelogo")!.resizeImage(targetSize: CGSize(width: 50, height: 50))?.cgImage {
                                    QRCodeViewUI(content: text, foregroundColor: CGColor(srgbRed: 166/255, green: 150/255, blue: 192/255, alpha: 1.0),
                                                 pixelStyle: QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 1, hasInnerCorners: true),
                                                 eyeStyle: QRCode.EyeShape.Squircle(),
                                                 logoTemplate: QRCode.LogoTemplate.CircleCenter(image: logoImage))
                                    .frame(width: 200, height: 200)
                                }
                            }
                            Text(viewModel.user?.name.uppercased() ?? "")
                                .font(.rubicBoldFont(size: 22))
                                .foregroundColor(Color(red: 114/255, green: 146/255, blue: 174/255))
                        }
                    }
                    Spacer()
                } else {
                    Spacer()
                    Text("check_internet_connection".localized)
                        .font(.poppinsBoldFont(size: 16))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
            }
            .padding(20)
        }
        .task {
            await viewModel.createFriendLink()
        }
    }
}

struct MyQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        MyQRCodeView(viewModel: HomeViewModel())
    }
}
