//
//  HomeView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text("HomeView")
            Button {
                viewModel.signOutBtnClicked()
            } label: {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(CustomColors.mainGradient)
                    .cornerRadius(20)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel(authService: AuthService()))
    }
}
