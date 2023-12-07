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
    @State private var underlineColor: Color = .gray
    @State private var isAnimating: Bool = false
    @State private var remainingTime = 59
    @State private var isTimerRunning = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("enter_code".localized)
                    .font(.rubicBoldFont(size: 32))
                    .foregroundStyle(CustomColors.darkBlue)
                
                HStack {
                    Text(viewModel.formattedPhoneNumber)
                        .font(.rubicRegularFont(size: 16))
                        .foregroundColor(.gray)
                        .padding(2)
                    Spacer()
                }
                .onAppear {
                    startTimer()
                }
                .onReceive(timer) { _ in
                    if self.remainingTime > 0 && self.isTimerRunning {
                        self.remainingTime -= 1
                    } else {
                        self.isTimerRunning = false
                        self.timer.upstream.connect().cancel()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CodeField()
                    .padding()
                
                Spacer()
                if isTimerRunning && remainingTime > 0 {
                    let seconds = appEnvironment.localizationManager.getLanguage() == .RU ? remainingTime.russianSecondsSuffix : remainingTime == 1 ? "second" : "seconds"
                    HStack {
                        Spacer()
                        Text(String(format: "resend_code_after".localized, remainingTime, seconds))
                            .font(.rubicRegularFont(size: 12))
                            .foregroundColor(.gray)
                            .padding(2)
                            .padding(.bottom)
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer()
                        Button {
                            startTimer()
                            viewModel.resendCode()
                            viewModel.codeFields = Array<String>(repeating: "", count: 6)
                            activeField = .field1
                        } label: {
                            Text("resend_button".localized)
                                .font(.rubicRegularFont(size: 12))
                                .foregroundStyle(CustomColors.darkBlue)
                                .padding(2)
                        }
                        .padding(.bottom)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 30)
            .onChange(of: viewModel.codeFields) { newValue in
                DOBConditions(value: newValue)
            }
            .overlay {
                if viewModel.isLoading {
                    RotatingShapesLoader(animate: $isAnimating, color: .black)
                        .frame(maxWidth: 80)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
        
    func startTimer() {
        self.isTimerRunning = true
        self.remainingTime = 59
    }
    
    @ViewBuilder
    func CodeField() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { index in
                CustomUnderlinedView(color: underlineColor) {
                    CustomTextField(text: $viewModel.codeFields[index]) {
                        handleBackspace(at: index)
                    }
                    .frame(height: 50)
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
    
    func handleBackspace(at index: Int) {
        if index > 0 && viewModel.codeFields[index].isEmpty {
            viewModel.codeFields[index - 1] = ""
            activeField = activeStateForIndex(index: index - 1)
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
        if value.joined().count == 6 && !viewModel.codeValidated {
            underlineColor = .red
        } else {
            underlineColor = .gray
        }
    }
}

struct CodeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CodeSettingsView()
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel(), authService: AuthService()))
    }
}
