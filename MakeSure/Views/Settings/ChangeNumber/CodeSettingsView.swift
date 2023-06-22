//
//  CodeSettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import SwiftUI

struct CodeSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @FocusState private var activeField: CodeFields?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("My code is")
                    .font(.rubicBoldFont(size: 44))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                HStack {
                    Text(viewModel.phoneNumber)
                        .font(.rubicRegularFont(size: 16))
                        .foregroundColor(CustomColors.darkGray)
                        .padding(2)
                    Button {
                        viewModel.resendCode()
                        viewModel.codeFields = Array<String>(repeating: "", count: 6)
                        activeField = .field1
                    } label: {
                        Text("resend_button".localized)
                            .font(.rubicRegularFont(size: 16))
                            .foregroundColor(.black)
                            .padding(2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            CodeField()
                .padding()
            
            Spacer()
        }
        .onChange(of: viewModel.codeFields) { newValue in
            DOBConditions(value: newValue)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    func CodeField() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { index in
                CustomUnderlinedView(color: CustomColors.darkGray) {
                    TextField("", text: $viewModel.codeFields[index])
                        .font(.interLightFont(size: 48))
                        .foregroundColor(.black)
                        .keyboardType(.numberPad)
                        .padding(.bottom, 2)
                        .multilineTextAlignment(.center)
                        .focused($activeField, equals: activeStateForIndex(index: index))
                        .onAppear {
                            DispatchQueue.main.async {
                                activeField = activeStateForIndex(index: index)
                            }
                        }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    func activeStateForIndex(index: Int) -> CodeFields {
        switch index {
        case 0: return .field1
        case 1: return .field2
        case 2: return .field3
        case 3: return .field4
        case 4: return .field5
        default: return .field6
        }
    }
    
    enum CodeFields: Int, CaseIterable {
        case field1, field2, field3, field4, field5, field6
    }
    
    func DOBConditions(value: [String]) {
        // moving next field if the current field is typed
        for index in 0..<5 {
            if value[index].count == 1 && activeStateForIndex(index: index) == activeField {
                activeField = activeStateForIndex(index: index + 1)
            }
        }

        // moving back if the current is empty and the previous is not empty
        for index in 1...5 {
            if value[index].isEmpty && !value[index - 1].isEmpty {
                activeField = activeStateForIndex(index: index - 1)
            }
        }

        // limiting only one text
        for index in 0..<6 {
            if value[index].count > 1 {
                viewModel.codeFields[index] = String(value[index].last!)
            }
        }

        viewModel.validateCode(value)
    }
}

struct CodeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CodeSettingsView()
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel()))
    }
}
