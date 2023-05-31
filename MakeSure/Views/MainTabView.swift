//
//  MainTabView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var viewModel: MainViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @ObservedObject private var contactsViewModel: ContactsViewModel
    @ObservedObject private var testsViewModel: TestsViewModel
    @ObservedObject private var scannerViewModel: ScannerViewModel
    @State private var showSettings = false
    
    @State private var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case privacySafety, help, addEmail, changePhoneNumber, legalPolicies, blacklist
        
        var id: Int {
            hashValue
        }
    }
    
    init() {
        _viewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getMainViewModel())
        _homeViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getHomeViewModel())
        _settingsViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getSettingsViewModel())
        _contactsViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getContactsViewModel())
        _testsViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getTestsViewModel())
        _scannerViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.getScannerViewModel())
    }
    
    var body: some View {
        ZStack {
            topNavigationBar
            tabView
            bottomNavigationBar
        }
        .contentShape(Rectangle())
        .background(.white)
        .onTapGesture {
            contactsViewModel.showCalendar = false
            homeViewModel.showPhotoMenu = false
        }
        .overlay {
            VStack {
                if contactsViewModel.showCalendar {
                    GraphicalDatePicker(viewModel: contactsViewModel, testsViewModel: testsViewModel, currentMonth: contactsViewModel.dateToStartInCalendar, isFromContactView: false)
                        .padding(.top, 50)
                    Spacer()
                }
            }
        }
        .overlay {
            Group {
                if showSettings {
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showSettings.toggle()
                            }
                        }
                    
                    SettingsView(
                        isShowing: $showSettings,
                        activeSheet: $activeSheet
                    )
                    .environmentObject(appEnvironment.viewModelFactory.getSettingsViewModel())
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .overlay {
            if let date = contactsViewModel.selectedDate {
                SelectContactForDateView(viewModel: contactsViewModel, date: date)
            }
        }
        .overlay {
            if homeViewModel.showMyQRCode {
                MyQRCodeView()
                    .environmentObject(homeViewModel)
            }
        }
        .overlay {
            if homeViewModel.showImagePhoto {
                ViewingImageView()
                    .environmentObject(homeViewModel)
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .privacySafety:
                PrivacySafetyView()
            case .help:
                HelpView()
            case .addEmail:
                EmailSettingsWrapperView(viewModel: settingsViewModel)
            case .changePhoneNumber:
                NumberSettingsWrapperView(viewModel: settingsViewModel)
            case .legalPolicies:
                LegalPoliciesView()
            case .blacklist:
                BlacklistView(viewModel: appEnvironment.viewModelFactory.getContactsViewModel(), homeViewModel: appEnvironment.viewModelFactory.getHomeViewModel())
            }
        }
    }
}

private extension MainTabView {
    var topNavigationBar: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        showSettings.toggle()
                    }
                } label: {
                    Image("menuNavBarIcon")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 25, height: 17)
                        .foregroundColor(viewModel.currentTab == .tests ||
                                         viewModel.currentTab == .scanner ? .white : .black)
                        .padding(.leading, 6)
                }
                Spacer()
                if contactsViewModel.isShowLinkIsCopied {
                    Text("link_copied_message".localized)
                        .font(.poppinsRegularFont(size: 17))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(CustomColors.fourthGradient)
                        )
                } else {
                    Text("MAKE SURE")
                        .font(.custom("BebasNeue", size: 28))
                        .overlay {
                            if viewModel.currentTab == .tests || viewModel.currentTab == .scanner {
                                CustomColors.whiteGradient
                                    .mask(
                                        Text("MAKE SURE")
                                            .font(.custom("BebasNeue", size: 28))
                                    )
                            } else {
                                CustomColors.secondGradient
                                    .mask(
                                        Text("MAKE SURE")
                                            .font(.custom("BebasNeue", size: 28))
                                    )
                            }
                        }
                }
                Spacer()
                HStack {
                    if viewModel.currentTab == .contacts || viewModel.currentTab == .tests {
                        Button(action: {
                            withAnimation {
                                contactsViewModel.showCalendar.toggle()
                            }
                        }) {
                            Image("calendarNavBarIcon")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 23, height: 23)
                                .foregroundColor(viewModel.currentTab == .tests ? .white : .black)
                        }
                    } else {
                        Button(action: {
                            homeViewModel.showMyQRCode.toggle()
                        }) {
                            Image("scannerNavBarIcon")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 18, height: 18)
                                .foregroundColor(viewModel.currentTab == .scanner ? .white : .black)
                        }
                    }
                    Button(action: {
                        // Add action to open notifications view
                    }) {
                        Image("notificationNavBarIcon")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 15, height: 19)
                            .foregroundColor(viewModel.currentTab == .tests || viewModel.currentTab == .scanner ? .white : .black)
                    }
                    .padding(.leading, 8)
                }
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 12)
            .background(viewModel.currentTab == .tests || viewModel.currentTab == .scanner ? Color.gradientPurple2 : .white)
            .zIndex(1)
            Spacer()
        }
    }
}

private extension MainTabView {
    var tabView: some View {
        Group {
            switch viewModel.currentTab {
            case .home:
                viewModel.currentTab.destinationView(viewModelFactory: appEnvironment.viewModelFactory)
            case .tests:
                viewModel.currentTab.destinationView(viewModelFactory: appEnvironment.viewModelFactory)
            case .scanner:
                viewModel.currentTab.destinationView(viewModelFactory: appEnvironment.viewModelFactory)
            case .contacts:
                viewModel.currentTab.destinationView(viewModelFactory: appEnvironment.viewModelFactory)
            }
        }
        .padding(.vertical, 38)
        .zIndex(0)
    }
}

private extension MainTabView {
    var bottomNavigationBar: some View {
        VStack {
            Spacer()
            HStack {
                ForEach(MainNavigation.allCases.indices, id: \.self) { index in
                    let tab = MainNavigation.allCases[index]
                    CustomTabItem(selection: tab, item: tab, isSelected: Binding(get: {
                        viewModel.currentTab == tab
                    }, set: { isSelected in
                        viewModel.currentTab = tab
                        if tab == .scanner, !scannerViewModel.isShowUser {
                            withAnimation {
                                scannerViewModel.isPresentingScanner = true
                            }
                        }
                    }), selectedIndex: $viewModel.currentTab)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
            .background(.white)
            .cornerRadius(12)
            .ignoresSafeArea(.all)
            .zIndex(1)
        }
    }
}

struct CustomTabItem: View {
    var selection: MainNavigation
    var item: MainNavigation
    @Binding var isSelected: Bool
    @Binding var selectedIndex: MainNavigation
    
    var body: some View {
        Button(action: {
            isSelected = true
            selectedIndex = selection
        }, label: {
            VStack {
                Image(item.imageName)
                    .resizable()
                    .frame(width: item.imageSize.width, height: item.imageSize.height)
                    .foregroundColor(CustomColors.purpleColor)
                    .padding(.top, item == .tests ? -5 : 0)
                Text(item.name)
                    .font(.poppinsMediumFont(size: 12))
                    .foregroundColor(CustomColors.purpleColor)
            }
        })
        .frame(height: 50)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
