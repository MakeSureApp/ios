//
//  SettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @Binding var isShowing: Bool
    @GestureState private var dragOffset = CGSize.zero
    @Binding var activeSheet: MainTabView.ActiveSheet?
    @State private var isShowingLanguageSelection = false
    @State private var isShowingDeleteAccountMenu = false
    @State private var isShowingSignOutAccountMenu = false
    @State private var isAnimating: Bool = false
    
    private var yOffset: CGFloat {
        isShowing ? UIScreen.main.bounds.height * 0.04 + dragOffset.height : UIScreen.main.bounds.height
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 50, height: 5)
                    .foregroundColor(Color.gradientDarkBlue2)
                    .padding(8)
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("settings".localized)
                            .font(.montserratLightFont(size: 24))
                            .foregroundColor(.white)
                            .padding(4)
                        //notificationsSection
                        languageSection
                        
                        
                        if viewModel.mainViewModel.user != nil {
                            emailSection
                            phoneSection
                            
                            //Help
                            IconAndTextItem(imageName: "HelpIcon", text: "help_section".localized) {
                                if let url = Constants.helpUrl {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            // Legal & Policies
                            IconAndTextItem(imageName: "LicenseIcon", text: "agreement".localized) {
                                if let url = Constants.agreementUrl {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            // Privacy & Safety
                            IconAndTextItem(imageName: "LockIcon", text: "privacy_section".localized) {
                                if let url = Constants.privacyUrl {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            // Blacklist
                            IconAndTextItem(imageName: "banIcon", text: "blacklist_section".localized, onTap: { activeSheet = .blacklist })
                            
                            // Delete Profile
                            IconAndTextItem(imageName: "BinIcon", text: "delete_profile_button".localized) {
                                withAnimation {
                                    isShowingDeleteAccountMenu = true
                                }
                            }
                            .alert(isPresented: $isShowingDeleteAccountMenu) {
                                Alert(
                                    title: Text("confirm_delete_account".localized),
                                    message: Text(""),
                                    primaryButton: .destructive(Text("delete_button".localized.uppercased())) {
                                        isShowingDeleteAccountMenu.toggle()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            
                            // SignOut
                            IconAndTextItem(imageName: "ExitIcon", text: "sign_out".localized) {
                                withAnimation {
                                    isShowingSignOutAccountMenu = true
                                }
                            }
                            .alert(isPresented: $isShowingSignOutAccountMenu) {
                                Alert(
                                    title: Text("you_sure_sign_out".localized),
                                    message: Text(""),
                                    primaryButton: .default(Text("sign_out".localized)) {
                                        isShowingDeleteAccountMenu.toggle()
                                        viewModel.signOutBtnClicked()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        } else {
                            VStack(alignment: .center) {
                                Spacer()
                                Text("check_internet_connection".localized)
                                    .font(.interSemiBoldFont(size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(8)
                //                Spacer()
                //                if viewModel.mainViewModel.user != nil {
                //                    Button {
                //                        viewModel.signOutBtnClicked()
                //                    } label: {
                //                        Text("sign_out".localized.uppercased())
                //                            .font(.montserratRegularFont(size: 20))
                //                            .frame(maxWidth: .infinity)
                //                            .foregroundColor(.white)
                //                            .padding()
                //                            .background(Color.gradientPurple2)
                //                            .cornerRadius(20)
                //                    }
                //                    .padding()
                //                    .padding(.bottom, 16)
                //                }
            }
            .background(CustomColors.thirdGradient.edgesIgnoringSafeArea(.all))
        }
        .frame(minHeight: UIScreen.main.bounds.height * 0.85)
        .cornerRadius(20, antialiased: true)
        .animation(.easeInOut, value: isShowing)
        .overlay(
            (isShowingLanguageSelection || isShowingDeleteAccountMenu || isShowingSignOutAccountMenu) ? Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(20)
                .onTapGesture {
                    withAnimation {
                        isShowingLanguageSelection = false
                        isShowingDeleteAccountMenu = false
                        isShowingSignOutAccountMenu = false
                    }
                } : nil)
        .offset(y: yOffset)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .updating($dragOffset, body: { value, state, _ in
                    if value.translation.height > 0 {
                        state = value.translation
                    }
                })
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
        )
        if isShowingLanguageSelection {
            LanguageSelectionView(selectedLanguage: $viewModel.selectedLanguage) { language in
                viewModel.selectedLanguage = language
                isShowingLanguageSelection = false
            }
            .offset(x: 80, y: 30)
        }
        //        if isShowingDeleteAccountMenu {
        //            AlertMenu(alertText: "confirm_delete_account".localized, actionBtnText: "delete_button".localized.uppercased(),
        //                      onCancel: {
        //                withAnimation {
        //                    isShowingDeleteAccountMenu.toggle()
        //                }
        //            }, onAction: {
        //                withAnimation {
        //                    isShowingDeleteAccountMenu.toggle()
        //                }
        //            })
        //        }
    }
}

private extension SettingsView {
    var notificationsSection: some View {
        HStack {
            Image("NotificationIcon")
                .resizable()
                .frame(width: 40, height: 40)
            Text("notifications_section".localized)
                .foregroundColor(.white)
                .font(.montserratRegularFont(size: 20))
                .padding(.leading, 4)
            Spacer()
            CustomSwitch(isOn: $viewModel.notificationsEnabled) {
                viewModel.toggleNotifications()
            }
            .padding(.trailing, 8)
        }
        .padding(4)
    }
}

private extension SettingsView {
    var languageSection: some View {
        HStack {
            Image("LanguageIcon")
                .resizable()
                .frame(width: 40, height: 40)
            Text("language_section".localized)
                .foregroundColor(.white)
                .font(.montserratRegularFont(size: 20))
                .padding(.leading, 4)
            Spacer()
            Button(action: {
                withAnimation {
                    isShowingLanguageSelection.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.purple)
                        .frame(width: 70, height: 30)
                    Text(viewModel.selectedLanguage.short)
                        .font(.montserratRegularFont(size: 16))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 8)
        }
        .padding(4)
    }
}

private extension SettingsView {
    var emailSection: some View {
        VStack {
            if let user = viewModel.mainViewModel.user {
                Button(action: { activeSheet = .addEmail }) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image("AtIcon")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text(user.email != nil ? "change_email".localized : "add_email".localized)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .font(.montserratRegularFont(size: 20))
                                .padding(.leading, 4)
                            Spacer()
                        }
                        if let email = user.email {
                            Text(viewModel.isVerified ? email : "not_verified_label".localized)
                                .font(.montserratRegularFont(size: 12))
                                .foregroundColor(.white)
                                .underline()
                                .padding(.leading, 50)
                        }
                    }
                    .padding(4)
                }
            }
        }
    }
}

private extension SettingsView {
    var phoneSection: some View {
        VStack {
            if let user = viewModel.mainViewModel.user {
                Button(action: { activeSheet = .changePhoneNumber }) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image("PhoneIcon")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("change_phone_number_button".localized)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .font(.montserratRegularFont(size: 20))
                                .padding(.leading, 4)
                            Spacer()
                        }
                        Text(user.phone)
                            .font(.montserratRegularFont(size: 12))
                            .foregroundColor(.white)
                            .underline()
                            .padding(.leading, 50)
                    }
                    .padding(4)
                }
            }
        }
    }
}

struct IconAndTextItem: View {
    let imageName: String
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                Text(text)
                    .font(.montserratRegularFont(size: 20))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
            }
            .padding(4)
        }
    }
    
}

struct CustomSwitch: View {
    @Binding var isOn: Bool
    var onToggle: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.purple)
            HStack {
                if isOn {
                    Text("on".localized.uppercased())
                        .font(.montserratRegularFont(size: 14))
                        .minimumScaleFactor(0.6)
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                    Spacer()
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                
                if !isOn {
                    Spacer()
                    Text("off".localized.uppercased())
                        .font(.montserratRegularFont(size: 14))
                        .minimumScaleFactor(0.6)
                        .foregroundColor(.white)
                        .padding(.trailing, 4)
                }
            }
            .onChange(of: isOn) { _ in
                onToggle()
            }
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
        }
        .frame(width: 70, height: 30)
    }
}





//struct DeleteAccView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertMenu(onCancel: {}, onDelete: {})
//    }
//}
