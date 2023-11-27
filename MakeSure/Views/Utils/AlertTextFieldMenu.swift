//
//  AlertTextFieldMenu.swift
//  MakeSure
//
//  Created by Macbook Pro on 27.11.2023.
//

import SwiftUI

struct AlertTextFieldMenu: View {
    let alertText: String
    let actionBtnText: String
    let placeholderText: String
    let onCancel: () -> Void
    let onAction: (String) -> Void
    
    @FocusState private var isInputActive: Bool
    @State private var isInvalidInput: Bool? = nil
    @State private var text = ""
    
    var body: some View {
        VStack {
            Text(alertText)
                .font(.montserratBoldFont(size: 18))
                .minimumScaleFactor(0.6)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            VStack {
                CustomUnderlinedView(color: .white, height: 0.2) {
                    TextField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholderText)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .foregroundStyle(.white)
                        .tint(.white)
                        .padding(4)
                        .focused($isInputActive)
                        .font(.montserratRegularFont(size: 16))
                        .onChange(of: text) { newValue in
                            if isInvalidInput != nil {
                                let _ = isValidInput()
                            }
                        }
                }
                if let isInvalid = isInvalidInput, isInvalid {
                    Text(getInputErrorText())
                        .font(.montserratBoldFont(size: 10))
                        .foregroundStyle(.red)
                }
            }
            .padding(.bottom)
            HStack {
                Button {
                    onCancel()
                } label: {
                    Text("cancel_button".localized.uppercased())
                        .font(.montserratBoldFont(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.gradientPurple2)
                        .cornerRadius(20)
                }
                Button {
                    if isValidInput() {
                        onAction(text)
                    }
                } label: {
                    Text(actionBtnText)
                        .font(.montserratBoldFont(size: 14))
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color(red: 1, green: 50.0/255.0, blue: 38.0/255.0))
                        .cornerRadius(20)
                }
            }
        }
        .onTapGesture {
            isInputActive = false
        }
        .padding()
        .background(CustomColors.thirdGradient)
        .cornerRadius(16)
        .frame(maxWidth: 300)
    }
    
    func isValidInput() -> Bool {
        let isValid = !text.isEmpty && text.count > 9
        isInvalidInput = !isValid
        return isValid
    }
    
    func getInputErrorText() -> String {
        return String(format: "field_shoud_contain_at_least".localized, 10)
    }
}

#Preview {
    AlertTextFieldMenu(alertText: "Hello", actionBtnText: "gfgfgfgfgdfnmjj", placeholderText: "explain_situation".localized, onCancel: {}, onAction: {_ in })
}
