//
//  MainTabView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
import BottomSheet

struct MainTabView: View {
    @State private var selectedIndex: Int = 0
    @ObservedObject private var viewModel: MainViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @ObservedObject private var contactsViewModel: ContactsViewModel
    @ObservedObject private var testsViewModel: TestsViewModel
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
    }
    
    var body: some View {
        
        let tabBarItems = MainNavigation.allCases
        
        let tabViews = ForEach(tabBarItems.indices, id: \.self) { index in
            NavigationView {
                tabBarItems[index]
                    .destinationView(viewModelFactory: appEnvironment.viewModelFactory)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            if contactsViewModel.isShowLinkIsCopied {
                                Text("Link is copied")
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
                                        if tabBarItems[index] == .tests {
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
                        }
                    }
                    .navigationBarItems(
                        leading:
                            Button(action: {
                                withAnimation {
                                    showSettings.toggle()
                                }
                            }) {
                                Image("menuNavBarIcon")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 25, height: 17)
                                    .foregroundColor(tabBarItems[index] == .tests ? .white : .black)
                                    .padding(.leading, 6)
                            },
                        trailing: HStack {
                            if tabBarItems[index] == .contacts || tabBarItems[index] == .tests {
                                Button(action: {
                                    withAnimation {
                                        contactsViewModel.showCalendar.toggle()
                                    }
                                }) {
                                    Image("calendarNavBarIcon")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 23, height: 23)
                                        .foregroundColor(tabBarItems[index] == .tests ? .white : .black)
                                }
                            } else {
                                Button(action: {
                                    homeViewModel.showMyQRCode.toggle()
                                }) {
                                    Image("scannerNavBarIcon")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.black)
                                }
                            }
                            Button(action: {
                                // Add action to open notifications view
                            }) {
                                Image("notificationNavBarIcon")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 15, height: 19)
                                    .foregroundColor(tabBarItems[index] == .tests ? .white : .black)
                            }
                        }
                            .padding(.trailing, 6)
                    )
            }
            .tag(index)
        }
        
        let tabView = TabView(selection: $selectedIndex) {
            tabViews
        }
        
        let customTabBar = HStack {
            ForEach(tabBarItems.indices, id: \.self) { index in
                CustomTabItem(selection: index, item: tabBarItems[index], isSelected: Binding(get: {
                    selectedIndex == index
                }, set: { isSelected in
                    selectedIndex = index
                }), selectedIndex: $selectedIndex)
                .frame(maxWidth: .infinity)
            }
        }
            .padding(.top, 8)
            .background(.white)
            .cornerRadius(12)
            .ignoresSafeArea(.all)
        
        return ZStack {
            VStack(spacing: 0) {
                tabView
                    .padding(.bottom, -50)
                customTabBar
            }
            .contentShape(Rectangle())
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
                            viewModel: appEnvironment.viewModelFactory.getSettingsViewModel(),
                            activeSheet: $activeSheet
                        )
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
                    MyQRCodeView(viewModel: homeViewModel)
                }
            }
            .overlay {
                if homeViewModel.showImagePhoto {
                    ViewingImageView(viewModel: homeViewModel)
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
}

struct CustomTabItem: View {
    var selection: Int
    var item: MainNavigation
    @Binding var isSelected: Bool
    @Binding var selectedIndex: Int
    
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
        .frame(height: 45)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
