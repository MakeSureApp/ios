//
//  OrderBoxViewModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 26.11.2023.
//

import Foundation

class OrderBoxViewModel: MainViewModel {
    
    @Published var mainViewModel: MainViewModel
    
    @Published var isOpenAddressAndDelivery: Bool = false
    @Published var isOpenAddress: Bool = false
    @Published var isOpenReceiver: Bool = false
    @Published var isOpenPaymentMethod: Bool = false
    
    // address fields
    @Published var city: String = "Москва"
    @Published var street: String = ""
    @Published var office: String = ""
    @Published var door: String = ""
    @Published var intercom: String = ""
    @Published var floor: String = ""
    
    //receiver fields
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    
    //payment
    struct PaymentMethod: Identifiable, Hashable {
        let id: String
        let name: String
        let icon: String
    }
    
    @Published var selectedPaymentMethod: PaymentMethod?
    let paymentMethods: [PaymentMethod] = [
        PaymentMethod(id: "sbp", name: "СБП", icon: "sbpPayment"),
        PaymentMethod(id: "online", name: "online_payment".localized, icon: "cardPayment"),
        PaymentMethod(id: "sberPay", name: "SberPay", icon: "SberPayPayment")
    ]
    
    @Published var comment: String = ""
    @Published var promocode: String = ""
    @Published var selectedCount = 1
    @Published var selectedTimeSlot: String?
    @Published var selectedDay: Date?
    
    var deliveryDetails: String {
        if city.isEmpty || street.isEmpty || street.count < 4 {
            return "select".localized
        } else {
            var str = "courier_delivery".localized.appending(" \n")
//            street = street.trimmingCharacters(in: .whitespacesAndNewlines)
//            if street.lowercased().starts(with: "ул ") {
//                street.removeFirst(3)
//            } else if street.lowercased().starts(with: "ул. ") {
//                street.removeFirst(4)
//            } else if street.lowercased().starts(with: "улица ") {
//                street.removeFirst(6)
//            }
            str.append("г. \(city), ул. \(street)")
            if !office.isEmpty {
                str.append(", \(office)")
            }
            return str
        }
    }
    
    var deliveryDetailsWithoutCity: String {
        if street.isEmpty || street.count < 4 {
            return "select".localized
        } else {
            var str = ""
//            street = street.trimmingCharacters(in: .whitespacesAndNewlines)
//            if street.lowercased().starts(with: "ул ") {
//                street.removeFirst(3)
//            } else if street.lowercased().starts(with: "ул. ") {
//                street.removeFirst(4)
//            } else if street.lowercased().starts(with: "улица ") {
//                street.removeFirst(6)
//            }
            str.append("ул. \(street)")
            if !office.isEmpty {
                str.append(", \(office)")
            }
            return str
        }
    }
    
    var contactDetails: String {
        if name.isEmpty && email.isEmpty && phone.isEmpty {
            return "not_set".localized
        } else {
            return "\(name)\n\n\(phone)\n\(email)"
        }
    }
    
    var chosenDate: String? {
        if let selectedDay {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            return dateFormatter.string(from: selectedDay)
        }
        return nil
    }
    
    @Published var deliveryPrice: Int = 0
    private let boxPrice = 1490
    var price: Int {
        return boxPrice * selectedCount
    }
    
    var totalPrice: Int {
        return deliveryPrice + price
    }
    
    @Published var messageForOrdering = "delivery_available_in_moscow_only".localized
    @Published var messageForOrdering2 = "if_you_are_in_another_city".localized
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        self.name = mainViewModel.user?.name ?? ""
        self.email = mainViewModel.user?.email ?? ""
        self.phone = mainViewModel.user?.phone ?? ""
    }
    
    
    func isFieldsValidated() -> Bool {
        return isAddressFieldsValid() && isReceiverFieldsValid() && isDeliveryFieldsValid() && selectedPaymentMethod != nil
    }
    
    func isAddressFieldsValid() -> Bool {
        return !street.isEmpty && street.count > 3
    }
    
    func isReceiverFieldsValid() -> Bool {
        return !name.isEmpty && name.count > 2 && !phone.isEmpty && phone.isPhoneNumber && !email.isEmpty && email.isValidEmail
    }
    
    func isDeliveryFieldsValid() -> Bool {
        return selectedDay != nil && selectedTimeSlot != nil && isAddressFieldsValid()
    }
    
    func closeWindow() {
        city = "Москва"
        street = ""
        office = ""
        door = ""
        floor = ""
        intercom = ""
        selectedDay = nil
        selectedCount = 1
        selectedTimeSlot = nil
        selectedPaymentMethod = nil
        comment = ""
        promocode = ""
        mainViewModel.showOrderBoxView = false
    }
}
