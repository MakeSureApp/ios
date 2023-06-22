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
                
                VStack(alignment: .leading) {
                    Text("settings".localized)
                        .font(.poppinsLightFont(size: 24))
                        .foregroundColor(.white)
                        .padding(4)
                    
                    // Privacy & Safety
                    Button(action: { activeSheet = .privacySafety }) {
                        HStack {
                            Image("PrivacySafetyIcon")
                                .foregroundColor(.white)
                            Text("privacy_safety_section".localized)
                                .font(.poppinsRegularFont(size: 20))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.leading, 6)
                        }
                        .padding(4)
                    }
                    
                    // Notifications
                    HStack {
                        Image("NotificationIcon")
                            .foregroundColor(.white)
                        Text("notifications_section".localized)
                            .foregroundColor(.white)
                            .font(.poppinsRegularFont(size: 20))
                            .padding(.leading, 6)
                        Spacer()
                        CustomSwitch(isOn: $viewModel.notificationsEnabled)
                            .padding(.trailing, 8)
                    }
                    .padding(4)
                    
                    // Language
                    HStack {
                        Image("LanguageIcon")
                            .foregroundColor(.white)
                        Text("language_section".localized)
                            .foregroundColor(.white)
                            .font(.poppinsRegularFont(size: 20))
                            .padding(.leading, 6)
                        Spacer()
                        Button(action: {
                            isShowingLanguageSelection.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.purple)
                                    .frame(width: 70, height: 30)
                                Text(viewModel.selectedLanguage.short)
                                    .font(.poppinsBoldFont(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 8)
                    }
                    .padding(4)
                    
                    //Help
                    Button(action: { activeSheet = .help }) {
                        HStack {
                            Image("HelpIcon")
                                .foregroundColor(.white)
                            Text("help_section".localized)
                                .font(.poppinsRegularFont(size: 20))
                                .foregroundColor(.white)
                                .padding(.leading, 6)
                        }
                        .padding(4)
                    }
                    
                    if let user = viewModel.mainViewModel.user {
                        // Email
                        Button(action: { activeSheet = .addEmail }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image("ChangeEmailIcon")
                                        .foregroundColor(.white)
                                    Text(user.email != nil ? "change_email".localized : "add_email".localized)
                                        .foregroundColor(.white)
                                        .font(.poppinsRegularFont(size: 20))
                                        .padding(.leading, 6)
                                }
                                if let email = user.email {
                                    Text(viewModel.isVerified ? email : "not_verified_label".localized)
                                        .font(.poppinsRegularFont(size: 12))
                                        .foregroundColor(.white)
                                        .underline()
                                        .padding(.leading, 30)
                                }
                            }
                            .padding(4)
                        }
                        
                        // Phone Number
                        Button(action: { activeSheet = .changePhoneNumber }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image("ChangePhoneNumberIcon")
                                        .foregroundColor(.white)
                                    Text("change_phone_number_button".localized)
                                        .foregroundColor(.white)
                                        .font(.poppinsRegularFont(size: 20))
                                        .padding(.leading, 6)
                                }
                                Text(user.phone)
                                    .font(.poppinsRegularFont(size: 12))
                                    .foregroundColor(.white)
                                    .underline()
                                    .padding(.leading, 30)
                            }
                            .padding(4)
                        }
                        
                        // Legal & Policies
                        Button(action: { activeSheet = .legalPolicies }) {
                            HStack {
                                Image("LegalPiliciesIcon")
                                    .foregroundColor(.white)
                                Text("legal_policies_section".localized)
                                    .font(.poppinsRegularFont(size: 20))
                                    .foregroundColor(.white)
                                    .padding(.leading, 6)
                            }
                            .padding(4)
                        }
                        
                        // Blacklist
                        Button(action: { activeSheet = .blacklist }) {
                            HStack {
                                Image("BlocklistIcon")
                                    .foregroundColor(.white)
                                Text("blacklist_section".localized)
                                    .font(.poppinsRegularFont(size: 20))
                                    .foregroundColor(.white)
                                    .padding(.leading, 6)
                            }
                            .padding(4)
                        }
                        
                        // Delete Profile
                        HStack {
                            Image("DeleteIcon")
                                .foregroundColor(.white)
                            Text("delete_profile_button".localized)
                                .font(.poppinsRegularFont(size: 20))
                                .foregroundColor(.white)
                                .padding(.leading, 6)
                        }
                        .padding(4)
                        
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
                .padding(8)
                .padding(.horizontal, 20)
                Spacer()
                if viewModel.mainViewModel.user != nil {
                    Button {
                        viewModel.signOutBtnClicked()
                    } label: {
                        Text("sign_out".localized.uppercased())
                            .font(.poppinsBoldFont(size: 20))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gradientPurple2)
                            .cornerRadius(20)
                    }
                    .padding()
                    .padding(.bottom, 16)
                }
            }
            .background(CustomColors.thirdGradient.edgesIgnoringSafeArea(.all))
        }
        .frame(minHeight: UIScreen.main.bounds.height * 0.85)
        .cornerRadius(20, antialiased: true)
        .animation(.easeInOut, value: isShowing)
        .overlay(
            isShowingLanguageSelection ? Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(20)
                .onTapGesture {
                    isShowingLanguageSelection = false
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
    }
}

struct CustomSwitch: View {
    @Binding var isOn: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.purple)
                .frame(width: 70, height: 30)
            HStack {
                if isOn {
                    Text("on".localized.uppercased())
                        .font(.poppinsBoldFont(size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .offset(x: isOn ? 0 : 4)
                
                if !isOn {
                    Text("off".localized.uppercased())
                        .font(.poppinsBoldFont(size: 16))
                        .minimumScaleFactor(0.7)
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
            }
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
        }
    }
}
