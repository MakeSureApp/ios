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
    @ObservedObject private var notificationsViewModel: NotificationsViewModel
    @ObservedObject private var orderBoxViewModel: OrderBoxViewModel
    @ObservedObject private var deeplinkHandler: DeeplinkHandler
    @State private var showSettings = false
    
    @State private var activeSheet: ActiveSheet?
    @State private var shouldPresentSendNotificationsToContactsView: Bool = false
    @State private var shouldPresentSearchedUserSheet: Bool = false
    
    enum ActiveSheet: Identifiable {
        case addEmail, changePhoneNumber, blacklist
        
        var id: Int {
            hashValue
        }
    }
    
    init() {
        let viewmodels = appEnvironment.viewModelFactory
        _viewModel = ObservedObject(wrappedValue: viewmodels.getMainViewModel())
        _homeViewModel = ObservedObject(wrappedValue: viewmodels.getHomeViewModel())
        _settingsViewModel = ObservedObject(wrappedValue: viewmodels.getSettingsViewModel())
        _contactsViewModel = ObservedObject(wrappedValue: viewmodels.getContactsViewModel())
        _testsViewModel = ObservedObject(wrappedValue: viewmodels.getTestsViewModel())
        _scannerViewModel = ObservedObject(wrappedValue: viewmodels.getScannerViewModel())
        _notificationsViewModel = ObservedObject(wrappedValue: viewmodels.getNotificationsViewModel())
        _orderBoxViewModel = ObservedObject(wrappedValue: viewmodels.getOrderBoxViewModel())
        _deeplinkHandler = ObservedObject(wrappedValue: appEnvironment.deeplinkHandler)
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
            homeViewModel.showPickPhotoMenu = false
        }
        .overlay {
            if contactsViewModel.showCalendar {
                VStack {
                    GraphicalDatePicker(viewModel: contactsViewModel, testsViewModel: testsViewModel, currentMonth: contactsViewModel.dateToStartInCalendar, isFromContactView: false)
                        .padding(.top, 50)
                    Spacer()
                }
            }
            if showSettings {
                Group {
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
            if let date = contactsViewModel.selectedDate {
                SelectContactForDateView(viewModel: contactsViewModel, date: date)
            }
            if homeViewModel.showMyQRCode {
                MyQRCodeView()
                    .environmentObject(homeViewModel)
            }
            if homeViewModel.showImagePhoto {
                ViewingImageView()
                    .environmentObject(homeViewModel)
            }
            if homeViewModel.showNotificationsView {
                NotificationsView()
                    .environmentObject(notificationsViewModel)
                    .environmentObject(homeViewModel)
            }
            if scannerViewModel.showSendNotificationsToContactsView {
                PositiveTestNotificationsWrapperView()
                    .environmentObject(scannerViewModel)
                    .environmentObject(contactsViewModel)
            }
            if viewModel.showOrderBoxView {
                OrderBoxView()
                    .environmentObject(orderBoxViewModel)
            }
        }
        .onChange(of: deeplinkHandler.deeplinkNavigation) { navigation in
            if let navigation {
                switch navigation {
                case .addContact(_):
                    shouldPresentSearchedUserSheet = true
                case .setUsername: break;
                case .profile:
                    viewModel.currentTab = .home
                    shouldPresentSearchedUserSheet = false
                    deeplinkHandler.deeplinkNavigation = nil
                }
            }
        }
        .sheet(isPresented: $shouldPresentSearchedUserSheet, onDismiss: {
            scannerViewModel.resetData()
            deeplinkHandler.addToContactWithUserId = nil
            deeplinkHandler.deeplinkNavigation = nil
        }) {
            if let userId = deeplinkHandler.addToContactWithUserId {
                SearchedUserView(isShowView: $shouldPresentSearchedUserSheet, userId: userId) {
                    scannerViewModel.resetData()
                    deeplinkHandler.addToContactWithUserId = nil
                    deeplinkHandler.deeplinkNavigation = nil
                }
                .environmentObject(scannerViewModel)
                .environmentObject(contactsViewModel)
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
//            case .privacySafety:
//                PrivacySafetyView()
//            case .help:
//                HelpView()
            case .addEmail:
                EmailSettingsWrapperView()
                    .environmentObject(settingsViewModel)
            case .changePhoneNumber:
                NumberSettingsWrapperView()
                    .environmentObject(settingsViewModel)
//            case .legalPolicies:
//                LegalPoliciesView()
            case .blacklist:
                BlacklistView()
                    .environmentObject(appEnvironment.viewModelFactory.getContactsViewModel())
                   
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
                        .frame(width: 24, height: 16)
                        .foregroundColor(viewModel.currentTab == .tests ||
                                         viewModel.currentTab == .scanner ? .white : CustomColors.darkBlue)
                        .padding(.leading, 12)
                }
                Spacer()
                if contactsViewModel.isShowLinkIsCopied {
                    Text("link_copied_message".localized)
                        .font(.montserratRegularFont(size: 17))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(CustomColors.fourthGradient)
                        )
                } else {
//                    Text("MAKE SURE")
//                        .font(.custom("BebasNeue", size: 28))
//                        .overlay {
//                            if viewModel.currentTab == .tests || viewModel.currentTab == .scanner {
//                                CustomColors.whiteGradient
//                                    .mask(
//                                        Text("MAKE SURE")
//                                            .font(.custom("BebasNeue", size: 28))
//                                    )
//                            } else {
//                                CustomColors.secondGradient
//                                    .mask(
//                                        Text("MAKE SURE")
//                                            .font(.custom("BebasNeue", size: 28))
//                                    )
//                            }
//                        }
                    Image("logoIcon")
                        .resizable()
                        .frame(width: 26, height: 26)
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
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.currentTab == .tests ? .white : CustomColors.darkBlue)
                        }
                    } else {
                        Button(action: {
                            homeViewModel.showMyQRCode.toggle()
                        }) {
                            Image("qrcodeIcon")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.currentTab == .scanner ? .white : CustomColors.darkBlue)
                        }
                    }
                    Button(action: {
                        withAnimation {
                            homeViewModel.showNotificationsView.toggle()
                        }
                    }) {
                        Image("bellIcon")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(viewModel.currentTab == .tests || viewModel.currentTab == .scanner ? .white : CustomColors.darkBlue)
                    }
                }
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
        .padding(.vertical, 32)
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
