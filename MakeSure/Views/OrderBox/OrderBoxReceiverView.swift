//
//  OrderBoxReceiver.swift
//  MakeSure
//
//  Created by Macbook Pro on 25.11.2023.
//

import SwiftUI

struct OrderBoxReceiverView: View {
    
    @EnvironmentObject var viewModel: OrderBoxViewModel
    
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        VStack(spacing: 26) {
            HStack {
                Button {
                    withAnimation {
                        viewModel.isOpenReceiver = false
                    }
                } label: {
                    Image("arrowIcon")
                        .resizable()
                        .rotationEffect(.degrees(180))
                        .frame(width: 12, height: 18)
                }
                Spacer()
                Text("recipient".localized)
                    .font(.montserratBoldFont(size: 18))
                    .foregroundStyle(.black)
                Spacer()
            }
            HStack {
                Text("your_information".localized)
                    .font(.montserratBoldFont(size: 22))
                    .foregroundStyle(.black)
                Spacer()
            }
            CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                TextField("first_name".localized, text: $viewModel.name)
                    .padding(4)
                    .focused($isInputActive)
                    .font(.montserratBoldFont(size: 18))
            }
            CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                TextField("phone_number".localized, text: $viewModel.phone)
                    .padding(4)
                    .focused($isInputActive)
                    .font(.montserratBoldFont(size: 18))
            }
            VStack {
                CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                    TextField("email", text: $viewModel.email)
                        .padding(4)
                        .focused($isInputActive)
                        .font(.montserratBoldFont(size: 18))
                }
                HStack {
                    Text("required_for_receipt".localized)
                        .font(.montserratRegularFont(size: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
            Spacer()
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.isReceiverFieldsValid()) {
                isInputActive = false
                withAnimation {
                    viewModel.isOpenReceiver = false
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
    OrderBoxReceiverView()
        .environmentObject(OrderBoxViewModel(mainViewModel: MainViewModel()))
}
