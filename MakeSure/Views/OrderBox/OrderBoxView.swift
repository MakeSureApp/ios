//
//  OrderBoxView.swift
//  MakeSure
//
//  Created by Macbook Pro on 25.11.2023.
//

import SwiftUI

struct OrderBoxView: View {
    
    @EnvironmentObject var viewModel: OrderBoxViewModel
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                HStack {
                    Text("order_processing".localized)
                        .font(.montserratBoldFont(size: 26))
                        .foregroundStyle(.black)
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.closeWindow()
                        }
                    } label: {
                        Image("closeIcon")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                }
                HStack {
                    Text(viewModel.messageForOrdering)
                        .font(.montserratRegularFont(size: 12))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text(viewModel.messageForOrdering2)
                        .font(.montserratRegularFont(size: 12))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    VStack(spacing: 0) {
                        Circle()
                            .frame(width: 4)
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 1)
                        Circle()
                            .frame(width: 4)
                    }
                    .padding(.vertical, 28)
                    VStack(spacing: 0) {
                        OrderBoxSectionDetailsView(title: "address_and_delivery".localized, details: viewModel.deliveryDetails, isIncludeArrow: true, count: nil, imageName: nil) {
                            withAnimation {
                                viewModel.isOpenAddressAndDelivery = true
                            }
                        }
                        OrderBoxSectionDetailsView(title: viewModel.chosenDate ?? "", details: viewModel.selectedTimeSlot, isIncludeArrow: false, count: viewModel.selectedCount, imageName: "boxImage", onTap: {})
                        OrderBoxSectionDetailsView(title: "recipient".localized, details: viewModel.contactDetails, isIncludeArrow: true, count: nil, imageName: nil) {
                            withAnimation {
                                viewModel.isOpenReceiver = true
                            }
                        }
                        OrderBoxSectionDetailsView(title: "payment".localized, details: viewModel.selectedPaymentMethod?.name, isIncludeArrow: true, count: nil, imageName: nil) {
                            withAnimation {
                                viewModel.isOpenPaymentMethod = true
                            }
                        }
                        Spacer()
                    }
                }
                HStack {
                    Text("order_amount".localized)
                        .font(.montserratBoldFont(size: 26))
                        .foregroundStyle(.black)
                    Spacer()
                }
                DashedBorderTextField(text: $viewModel.promocode, isInputActive: _isInputActive)
                OrderBoxSummarySectionView(price: viewModel.price, deliveryPrice: viewModel.deliveryPrice)
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("total".localized.uppercased())
                            .font(.montserratBoldFont(size: 20))
                            .foregroundStyle(.black)
                        Text("\(viewModel.totalPrice) ₽")
                            .font(.montserratBoldFont(size: 16))
                            .foregroundStyle(.black)
                    }
                }
                Spacer()
                    .frame(minHeight: 20)
                RoundedGradientButton(text: "place_order".localized, isEnabled: viewModel.isFieldsValidated()) {
                    isInputActive = false
                    withAnimation {
                        viewModel.closeWindow()
                    }
                }
            }
            .padding(.horizontal, 24)
        }.onTapGesture {
            isInputActive = false
        }
        .background(.white)
        .overlay {
            if viewModel.isOpenAddressAndDelivery {
                OrderBoxAddressAndDeliveryView()
                    .environmentObject(viewModel)
            }
            if viewModel.isOpenReceiver {
                OrderBoxReceiverView()
                    .environmentObject(viewModel)
            }
            if viewModel.isOpenPaymentMethod {
                OrderBoxPaymentView()
                    .environmentObject(viewModel)
            }
        }
    }
}


struct OrderBoxSectionDetailsView: View {
    let title: String
    let details: String?
    let isIncludeArrow: Bool
    let count: Int?
    let imageName: String?
    let onTap: () -> Void?
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 16)
            VStack {
                HStack {
                    Text(title)
                        .font(.montserratBoldFont(size: 22))
                        .foregroundStyle(.black)
                    Spacer()
                    if isIncludeArrow {
                        Button {
                            
                        } label: {
                            Image("arrowIcon")
                                .resizable()
                                .frame(width: 10, height: 16)
                        }
                    }
                }
                HStack {
                    Text(details ?? "not_selected".localized)
                        .font(.montserratRegularFont(size: 12))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                if let imageName, let count {
                    HStack {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 120)
                        
                        Text("x \(count)")
                            .font(.montserratRegularFont(size: 16))
                            .foregroundStyle(.black)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct DashedBorderTextField: View {
    @Binding var text: String
    @FocusState var isInputActive: Bool
    
    var body: some View {
        TextField("enter_promo_code".localized, text: $text)
            .focused($isInputActive)
            .font(.montserratRegularFont(size: 16))
            .padding()
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundColor(.gray)
            )
            
    }
}

struct OrderBoxSummarySectionView: View {
    
    var price: Int
    var deliveryPrice: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("order_amount".localized)
                    .font(.montserratRegularFont(size: 14))
                    .foregroundStyle(.black)
                Spacer()
                Text("\(price) ₽")
                    .font(.montserratBoldFont(size: 14))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("delivery".localized)
                    .font(.montserratRegularFont(size: 14))
                    .foregroundStyle(.black)
                Spacer()
                Text(deliveryPrice == 0 ? "free".localized : "\(deliveryPrice) ₽")
                    .font(.montserratBoldFont(size: 14))
                    .foregroundStyle(.black)
            }
        }
        .padding(.vertical, 16)
    }
}


#Preview {
    OrderBoxView()
        .environmentObject(OrderBoxViewModel(mainViewModel: MainViewModel()))
}
