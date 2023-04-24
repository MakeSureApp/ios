//
//  MainTabView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        let tabBarItems = MainNavigation.allCases
        
        let tabViews = ForEach(tabBarItems.indices, id: \.self) { index in
            NavigationView {
                tabBarItems[index].destinationView
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
        .frame(height: 50)
        .padding(.top, 40)
        .background(.white)
        
        return ZStack(alignment: .bottom) {
            tabView
            customTabBar
        }
        .ignoresSafeArea()

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
        .padding(.bottom, 50)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(viewModel: MainViewModel(authService: AuthService()))
    }
}
