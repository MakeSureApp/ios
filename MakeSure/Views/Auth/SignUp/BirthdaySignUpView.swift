//
//  BirthdayView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct BirthdaySignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    let placeholders = [
        "day_placeholder".localized,
        "day_placeholder".localized,
        "month_placeholder".localized,
        "month_placeholder".localized,
        "year_placeholder".localized,
        "year_placeholder".localized,
        "year_placeholder".localized,
        "year_placeholder".localized
    ]

    @FocusState private var activeField: FieldIndex?

    var body: some View {
        VStack {
            // Title
            Text("my_birthday_is".localized)
                .font(.rubicBoldFont(size: 44))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            // Birthday input
            HStack {
                BirthdayField()
                    .padding()
                Spacer(minLength: 80)
            }

            Spacer()
        }
        .onChange(of: viewModel.birthdayFields) { newValue in
            DOBConditions(value: newValue)
        }
    }

    @ViewBuilder
    func BirthdayField() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<8, id: \.self) { index in
                if index == 2 || index == 4 {
                    Text("/")
                        .font(.interRegularFont(size: 28))
                        .foregroundColor(.gray)
                }
                CustomUnderlinedView(color: CustomColors.darkGray) {
                    TextField("", text: $viewModel.birthdayFields[index])
                        .font(.interRegularFont(size: 23))
                        .foregroundColor(.black)
                        .keyboardType(.numberPad)
                        .padding(.bottom, 4)
                        .multilineTextAlignment(.center)
                        .focused($activeField, equals: activeStateForIndex(index: index))
                        .onAppear {
                            DispatchQueue.main.async {
                                activeField = activeStateForIndex(index: index)
                            }
                        }
                        .overlay(
                            Text(placeholders[index])
                                .font(.interRegularFont(size: 28))
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                                .opacity(viewModel.birthdayFields[index].isEmpty ? 1 : 0))
                }
            }
        }
    }

    func activeStateForIndex(index: Int) -> FieldIndex {
        return FieldIndex(rawValue: index) ?? .field0
    }

    enum FieldIndex: Int {
        case field0, field1, field2, field3, field4, field5, field6, field7
    }

    func DOBConditions(value: [String]) {
        // moving next field if the current field is typed
        for index in 0..<7 {
            if value[index].count == 1 && activeStateForIndex(index: index) == activeField {
                activeField = activeStateForIndex(index: index + 1)
            }
        }

        // moving back if the current is empty and the previous is not empty
        for index in 1...7 {
            if value[index].isEmpty && !value[index - 1].isEmpty {
                activeField = activeStateForIndex(index: index - 1)
            }
        }

        // limiting only one text
        for index in 0..<8 {
            if value[index].count > 1 {
                viewModel.birthdayFields[index] = String(value[index].last!)
            }
        }

        viewModel.validateBirtday(value)
    }
}

struct BirthdaySignUpView_Previews: PreviewProvider {
    static var previews: some View {
        BirthdaySignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
