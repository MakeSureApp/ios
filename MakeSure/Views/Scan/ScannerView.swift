//
//  ScannerView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import AVFoundation
import SwiftUI
import CodeScanner

struct ScannerView: View {
    @EnvironmentObject var viewModel: ScannerViewModel
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var isAnimating: Bool = false
    @State private var isShowUserView: Bool = false
    @State private var isTestCamera: Bool = true
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                if let code = viewModel.scannedCode {
                    SearchedUserView(isShowView: $isShowUserView, userId: code, onDismiss: {})
                        .environmentObject(viewModel)
                        .environmentObject(contactsViewModel)
                } else if viewModel.isLoading || contactsViewModel.isAddingUserToContacts {
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
                            .font(.montserratBoldFont(size: 30))
                            .foregroundColor(.white)
                            .padding()
                        Text("added_to_contacts".localized)
                            .font(.montserratBoldFont(size: 20))
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
                } else if viewModel.hasLoaded, let response = viewModel.testResponse {
                    Text(response)
                        .font(.montserratBoldFont(size: 20))
                        .foregroundColor(.white)
                        .padding()
                    if viewModel.isLoadingHighRiskUsers || viewModel.isLoadingHighRiskUsers || viewModel.isSendingNotifications {
                        RotatingShapesLoader(animate: $isAnimating)
                            .frame(maxWidth: 70)
                            .padding(.top, 20)
                            .onAppear {
                                isAnimating = true
                            }
                            .onDisappear {
                                isAnimating = false
                            }
                    }
                } else if viewModel.showPositiveTestView, let testName = viewModel.positiveTestName {
                    VStack {
                        VStack {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("do_not_panic".localized)
                                        .font(.montserratBoldFont(size: 20))
                                        .foregroundStyle(CustomColors.darkBlue)
                                    Spacer()
                                    Image("logoIcon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .padding(.top)
                                Text(String(format: "positive_test_description".localized, testName))
                                    .font(.montserratRegularFont(size: 16))
                                    .foregroundStyle(CustomColors.darkBlue)
                                    .padding(.bottom)
                                HStack {
                                    Spacer()
                                        .frame(alignment: .leading)
                                    RoundedGradientButton(text: "notify".localized, isEnabled: true, textSize: 16) {
                                        viewModel.showSendNotificationsToContactsView = true
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                        )
                        .padding()
                        
                        Spacer()
                    }
                } else if viewModel.showNegativeTestView {
                    VStack {
                        VStack {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("great".localized)
                                        .font(.montserratBoldFont(size: 20))
                                        .foregroundStyle(CustomColors.darkBlue)
                                    Spacer()
                                    Image("logoIcon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .padding(.top)
                                HStack {
                                    Text("negative_tests_uploaded".localized)
                                        .font(.montserratRegularFont(size: 16))
                                        .foregroundStyle(CustomColors.darkBlue)
                                        .padding(.bottom)
                                    Spacer()
                                }
                                Image("congratsNegativeTest")
                                    .resizable()
                                    .frame(width: .infinity)
                                    .scaledToFit()
                                    .padding(.bottom)
                                   
                                HStack {
                                    Spacer()
                                        .frame(alignment: .leading)
                                    RoundedGradientButton(text: "OK", isEnabled: true) {
                                        withAnimation {
                                            viewModel.resetData(showScanner: false)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                        )
                        .padding()
                        
                        Spacer()
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.montserratBoldFont(size: 20))
                        .foregroundColor(.white)
                        .padding()
                } else if !viewModel.isShowUser {
                    Spacer()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    //                                    self.viewModel.isPresentingScanner = true
                                }
                            }
                        }
                }
            }
            .padding(.bottom, 40)
        }
        .task {
            if contactsViewModel.contacts.isEmpty {
                await contactsViewModel.fetchContacts()
            }
        }
        .sheet(isPresented: $viewModel.isPresentingScanner) {
            ZStack {
                if isTestCamera {
                    ZStack {
                        if let image = viewModel.capturedImage {
                            CapturedImageView(image: image, onRetry: viewModel.retry, onSend: viewModel.send)
                                .ignoresSafeArea(.all)
                        } else {
                            CameraView(session: viewModel.session, takePhoto: viewModel.takePhoto)
                        }
                    }
                    .onAppear(perform: viewModel.setupSession)
                    .onDisappear(perform: viewModel.tearDownSession)
                } else {
                    CodeScannerView(codeTypes: [.qr]) { response in
                        if case let .success(result) = response {
                            print(result)
                            viewModel.scannedCode = result.string
                            viewModel.isPresentingScanner = false
                        }
                    }
                }
                if viewModel.capturedImage == nil {
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                isTestCamera = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("scan_test".localized)
                                        .font(.montserratBoldFont(size: 23))
                                        .foregroundColor(isTestCamera ? .white : Color.gradientDarkBlue)
                                        .shadow(color: isTestCamera ? .clear : .white, radius: 6)
                                        .padding()
                                    Spacer()
                                }
                            }
                            .background(isTestCamera ? CustomColors.thirdGradient : CustomColors.clearGradient)
                            .cornerRadius(20, corners: [.bottomRight, .topRight])
                            .shadow(radius: 6)
                            
                            Button {
                                isTestCamera = false
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("scan_user".localized)
                                        .font(.montserratBoldFont(size: 23))
                                        .scaledToFit()
                                        .minimumScaleFactor(0.5)
                                        .foregroundColor(isTestCamera ? Color.gradientDarkBlue : .white)
                                        .shadow(color: isTestCamera ? .white : .clear, radius: 6)
                                        .padding()
                                    Spacer()
                                }
                            }
                            .background(isTestCamera ? CustomColors.clearGradient : CustomColors.thirdGradient )
                            .cornerRadius(20, corners: [.bottomLeft, .topLeft])
                            .shadow(radius: 6)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct CameraView: View {
    var session: AVCaptureSession
    let takePhoto: () -> Void

    var body: some View {
        ZStack {
            CameraPreview(session: session)
            VStack {
                Spacer()
                CaptureButton(takePhoto: takePhoto)
                Spacer().frame(height: 100)
            }
        }
    }
}

struct CapturedImageView: View {
    let image: UIImage
    let onRetry: () -> Void
    let onSend: () -> Void

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack {
                Spacer()
                HStack {
                    Button {
                        onRetry()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                    }
                    .shadow(color: .black, radius: 6)
                    Spacer()
                    Button {
                        onSend()
                    } label: {
                        HStack {
                            Text("send".localized.uppercased())
                                .font(.montserratBoldFont(size: 20))
                                .foregroundColor(.white)
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .scaledToFit()
                                .rotationEffect(Angle(degrees: 45))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.horizontal, 8)
                        .padding()
                        .background(CustomColors.thirdGradient)
                        .cornerRadius(20)
                        .shadow(color: .white, radius: 6)
                    }
                }
                .padding()
                Spacer().frame(height: 20)
            }
        }
    }
}

struct CaptureButton: View {
    let takePhoto: () -> Void

    var body: some View {
        Button(action: {
            takePhoto()
        }) {
            Image(systemName: "camera.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .padding(30)
                .background(CustomColors.thirdGradient)
                .clipShape(Circle())
                .shadow(color: CustomColors.purpleColor, radius: 10)
        }
    }
}

//struct CaptureButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        HStack {
//            Button {
//               // onRetry
//            } label: {
//                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(.white)
//                    .frame(width: 50, height: 50)
//            }
//
//            Button {
//                //onSend
//            } label: {
//                HStack {
//                    Text("send".localized.uppercased())
//                        .font(.montserratBoldFont(size: 25))
//                        .foregroundColor(.white)
//                    Image(systemName: "paperplane.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .rotationEffect(Angle(degrees: 45))
//                        .foregroundColor(.white)
//                        .frame(width: 30, height: 30)
//                }
//                .padding()
//                .background(CustomColors.thirdGradient)
//                .cornerRadius(20)
//                .shadow(color: .white, radius: 12)
//            }
//
//        }
//        .padding()
//        .background(.black)
//    }
//}

//struct ScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScannerView()
//            .environmentObject(ScannerViewModel())
//            .environmentObject(ContactsViewModel())
//            .environmentObject(MainViewModel())
//    }
//}

#Preview(body: {
    ZStack {
        CustomColors.thirdGradient
            .ignoresSafeArea(.all)
        VStack {
            VStack {
                VStack(spacing: 12) {
                    HStack {
                        Text("great".localized)
                            .font(.montserratBoldFont(size: 20))
                            .foregroundStyle(CustomColors.darkBlue)
                        Spacer()
                        Image("logoIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.top)
                    HStack {
                        Text("negative_tests_uploaded".localized)
                            .font(.montserratRegularFont(size: 16))
                            .foregroundStyle(CustomColors.darkBlue)
                            .padding(.bottom)
                        Spacer()
                    }
                    Image("congratsNegativeTest")
                        .resizable()
                        .frame(width: .infinity)
                        .scaledToFit()
                        .padding(.bottom)
                       
                    HStack {
                        Spacer()
                            .frame(alignment: .leading)
                        RoundedGradientButton(text: "OK", isEnabled: true) {
                            
                        }
                    }
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
})
