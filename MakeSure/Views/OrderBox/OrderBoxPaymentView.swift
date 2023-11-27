//
//  OrderBoxPayment.swift
//  MakeSure
//
//  Created by Macbook Pro on 25.11.2023.
//

import SwiftUI

struct OrderBoxPaymentView: View {
    
    @EnvironmentObject var viewModel: OrderBoxViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        viewModel.isOpenPaymentMethod = false
                    }
                } label: {
                    Image("arrowIcon")
                        .resizable()
                        .rotationEffect(.degrees(180))
                        .frame(width: 12, height: 18)
                }
                Spacer()
                Text("payment_method".localized)
                    .font(.montserratBoldFont(size: 18))
                    .foregroundStyle(.black)
                Spacer()
            }
            Spacer()
                .frame(height: 40)
            ForEach(viewModel.paymentMethods) { method in
                HStack {
                    Image(systemName: viewModel.selectedPaymentMethod == method ? "largecircle.fill.circle" : "circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(viewModel.selectedPaymentMethod == method ? .purple : .gray)
                        .onTapGesture {
                            viewModel.selectedPaymentMethod = method
                        }
                    
                    Text(method.name)
                        .font(.montserratBoldFont(size: 22))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Image(method.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .contentShape(Rectangle())
                .padding(5)
                .onTapGesture {
                    viewModel.selectedPaymentMethod = method
                }
            }
            Spacer()
            RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: viewModel.selectedPaymentMethod != nil) {
                withAnimation {
                    viewModel.isOpenPaymentMethod = false
                }
            }
        }
        .padding(.horizontal, 24)
        .background(.white)
    }
}

#Preview {
    OrderBoxPaymentView()
        .environmentObject(OrderBoxViewModel(mainViewModel: MainViewModel()))
}
