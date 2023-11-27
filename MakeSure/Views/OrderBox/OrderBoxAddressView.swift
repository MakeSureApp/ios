//
//  OrderBoxAddressView.swift
//  MakeSure
//
//  Created by Macbook Pro on 25.11.2023.
//

import SwiftUI

struct OrderBoxAddressView: View {
    
    @EnvironmentObject var viewModel: OrderBoxViewModel
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button {
                    withAnimation {
                        viewModel.isOpenAddress = false
                    }
                } label: {
                    Image("arrowIcon")
                        .resizable()
                        .rotationEffect(.degrees(180))
                        .frame(width: 12, height: 18)
                }
                Spacer()
                Text("address".localized)
                    .font(.montserratBoldFont(size: 18))
                    .foregroundStyle(.black)
                Spacer()
            }
            VStack(spacing: 10) {
                HStack {
                    Text("city".localized)
                        .font(.montserratBoldFont(size: 22))
                        .foregroundStyle(.black)
                    Spacer()
                }
                HStack {
                    Text("г. Москва")
                        .font(.montserratRegularFont(size: 12))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                TextField("street_and_house".localized, text: $viewModel.street)
                    .padding(4)
                    .focused($isInputActive)
                    .font(.montserratBoldFont(size: 18))
            }
            VStack(spacing: 10) {
                HStack {
                    CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                        TextField("apt_or_office".localized, text: $viewModel.office)
                            .padding(4)
                            .focused($isInputActive)
                            .font(.montserratBoldFont(size: 18))
                    }
                    Spacer()
                        .frame(width: 50)
                    CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                        TextField("intercom".localized, text: $viewModel.intercom)
                            .padding(4)
                            .focused($isInputActive)
                            .font(.montserratBoldFont(size: 18))
                    }
                }
                HStack {
                    CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                        TextField("entrance".localized, text: $viewModel.door)
                            .padding(4)
                            .focused($isInputActive)
                            .font(.montserratBoldFont(size: 18))
                    }
                    Spacer()
                        .frame(width: 50)
                    CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                        TextField("floor".localized, text: $viewModel.floor)
                            .padding(4)
                            .focused($isInputActive)
                            .font(.montserratBoldFont(size: 18))
                    }
                }
            }
            Spacer()
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.isAddressFieldsValid()) {
                isInputActive = false
                withAnimation {
                    viewModel.isOpenAddress = false
                }
            }
        }
        .padding(.horizontal, 24)
        .background(.white)
        .onTapGesture {
            isInputActive = false
        }
    }
}

#Preview {
    OrderBoxAddressView()
        .environmentObject(OrderBoxViewModel(mainViewModel: MainViewModel()))
}
