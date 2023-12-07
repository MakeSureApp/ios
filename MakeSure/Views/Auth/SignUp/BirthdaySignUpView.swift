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
    @State private var underlineColor: Color = .gray

    var body: some View {
        VStack {
            // Title
            Text("birthday".localized)
                .font(.rubicBoldFont(size: 32))
                .foregroundStyle(CustomColors.darkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            
            HStack {
                Text("to_congratulate_you".localized)
                    .font(.rubicRegularFont(size: 16))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.bottom, 30)

            // Birthday input
            HStack {
                BirthdayField()
                Spacer(minLength: 80)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .contentShape(Rectangle())
        .onTapGesture {
            activeField = nil
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
                        .font(.rubicRegularFont(size: 24))
                        .foregroundColor(.gray.opacity(0.5))
                }
                CustomUnderlinedView(color: underlineColor) {
                    CustomTextField(text: $viewModel.birthdayFields[index]) {
                        handleBackspace(at: index)
                    }
                    .frame(height: 50)
                    .focused($activeField, equals: activeStateForIndex(index: index))
                    .onAppear {
                        DispatchQueue.main.async {
                            activeField = activeStateForIndex(index: index)
                        }
                    }
                    .overlay(
                        Text(placeholders[index])
                            .font(.rubicRegularFont(size: 24))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 2)
                            .opacity(viewModel.birthdayFields[index].isEmpty ? 1 : 0))
                }
            }
        }
    }
    
    func handleBackspace(at index: Int) {
        if index > 0 && viewModel.birthdayFields[index].isEmpty {
            viewModel.birthdayFields[index - 1] = ""
            activeField = activeStateForIndex(index: index - 1)
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
//        for index in 1...7 {
//            if value[index].isEmpty && !value[index - 1].isEmpty {
//                activeField = activeStateForIndex(index: index - 1)
//            }
//        }

        // limiting only one text
        for index in 0..<8 {
            if value[index].count > 1 {
                viewModel.birthdayFields[index] = String(value[index].last!)
            }
        }

        viewModel.validateBirtday(value)
        if value.joined().count == 8 && !viewModel.birthdayValidated {
            underlineColor = .red
        } else {
            underlineColor = .gray
        }
    }
}

struct BirthdaySignUpView_Previews: PreviewProvider {
    static var previews: some View {
        BirthdaySignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
