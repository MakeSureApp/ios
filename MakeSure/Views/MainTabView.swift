//
//  MainTabView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex: Int = 0
    @EnvironmentObject var appEnvironment: AppEnvironment
    @ObservedObject private var viewModel: MainViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @ObservedObject private var contactsViewModel: ContactsViewModel
    @State private var showSettings = false
    
    @State private var activeSheet: ActiveSheet?
    
    @State private var currentDate = Date()
    
    enum ActiveSheet: Identifiable {
        case privacySafety, help, addEmail, changePhoneNumber, legalPolicies, blacklist
        
        var id: Int {
            hashValue
        }
    }
    
    init(appEnvironment: AppEnvironment) {
        _viewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.makeMainViewModel())
        _settingsViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.makeSettingsViewModel())
        _contactsViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.makeContactsViewModel())
    }
    
    var body: some View {
        
        let tabBarItems = MainNavigation.allCases
        
        let tabViews = ForEach(tabBarItems.indices, id: \.self) { index in
            NavigationView {
                tabBarItems[index].destinationView(viewModelFactory: appEnvironment.viewModelFactory)
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
                                        CustomColors.secondGradient
                                            .mask(
                                                Text("MAKE SURE")
                                                    .font(.custom("BebasNeue", size: 28))
                                            )
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
                                .frame(width: 25, height: 17)
                                .foregroundColor(.black)
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
                                        .frame(width: 23, height: 23)
                                        .foregroundColor(.black)
                                }
                            } else {
                                Button(action: {
                                    // Add action to open scanner view
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
                                    .frame(width: 15, height: 19)
                                    .foregroundColor(.black)
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
            .onChange(of: selectedIndex) { index in
                //coordinator.navigate(to: tabBarItems[index])
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
            .ignoresSafeArea(.all)
        
        return ZStack {
            VStack(spacing: 0) {
                tabView
                    .padding(.bottom, -50)
                customTabBar
            }
            .overlay {
                VStack {
                    if contactsViewModel.showCalendar {
                        GraphicalDatePicker(startDate: contactsViewModel.startDateInCalendar, metContacts: contactsViewModel.contacts, testsDates: contactsViewModel.getTestsDates(), currentMonth: $currentDate)
                            .edgesIgnoringSafeArea(.all)
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
                            viewModel: appEnvironment.viewModelFactory.makeSettingsViewModel(),
                            activeSheet: $activeSheet
                        )
                        .transition(.move(edge: .bottom))
                    }
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
                    BlacklistView(viewModel: appEnvironment.viewModelFactory.makeContactsViewModel())
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
        MainTabView(appEnvironment: AppEnvironment())
            .environmentObject(AppEnvironment())
    }
}
