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
    @State private var showSettings = false
    
    @State private var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case privacySafety, help, addEmail, changePhoneNumber, legalPolicies, blacklist
        
        var id: Int {
            hashValue
        }
    }
    
    init(appEnvironment: AppEnvironment) {
        _viewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.makeMainViewModel())
        _settingsViewModel = ObservedObject(wrappedValue: appEnvironment.viewModelFactory.makeSettingsViewModel())
    }
    
    var body: some View {
        
        let tabBarItems = MainNavigation.allCases
        
        let tabViews = ForEach(tabBarItems.indices, id: \.self) { index in
            NavigationView {
                tabBarItems[index].destinationView(viewModelFactory: appEnvironment.viewModelFactory)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
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
                    .navigationBarItems(
                        leading: Button(action: {
                            withAnimation {
                                showSettings.toggle()
                            }
                        }) {
                            Image("menuNavBarIcon")
                                .foregroundColor(.black)
                        },
                        trailing: HStack {
                            Button(action: {
                                // Add action to open scanner view
                            }) {
                                Image("scannerNavBarIcon")
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {
                                // Add action to open notifications view
                            }) {
                                Image("notificationNavBarIcon")
                                    .foregroundColor(.black)
                            }
                        }
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
                CustomTabItem(selection: index, imageName: tabBarItems[index].imageName, name: tabBarItems[index].name, isSelected: Binding(get: {
                    selectedIndex == index
                }, set: { isSelected in
                    selectedIndex = index
                }), selectedIndex: $selectedIndex)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 40)
        .padding(.top, 40)
        .background(.white)
        
        return ZStack {
            VStack {
                tabView
                customTabBar
            }
            .overlay(
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
            )
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
    var imageName: String
    var name: String
    @Binding var isSelected: Bool
    @Binding var selectedIndex: Int
    
    var body: some View {
        Button(action: {
            isSelected = true
            selectedIndex = selection
        }, label: {
            VStack {
                Image(imageName)
                    .foregroundColor(CustomColors.purpleColor)
                Text(name)
                    .font(.poppinsMediumFont(size: 12))
                    .foregroundColor(CustomColors.purpleColor)
            }
        })
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(appEnvironment: AppEnvironment())
    }
}
