//
//  MyNumberView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI
import NavigationStack

struct NumberSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @State private var showCountryPicker = false
    @State private var isAnimating: Bool = false
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        ZStack {
            VStack {
                // Title
                Text("phone_number".localized)
                    .font(.rubicBoldFont(size: 32))
                    .foregroundStyle(CustomColors.darkBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                
                // Country code and phone number input
                HStack {
                    CustomUnderlinedView {
                        Button(action: {
                            showCountryPicker.toggle()
                        }) {
                            HStack {
                                Text(viewModel.countryCode.description)
                                    .font(.rubicRegularFont(size: 23))
                                    .foregroundStyle(CustomColors.darkBlue)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "arrowtriangle.down.fill")
                                    .resizable()
                                    .foregroundStyle(CustomColors.darkBlue)
                                    .frame(width: 12, height: 6)
                                    .foregroundColor(.black)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: 120)
                    
                    CustomUnderlinedView {
                        TextField("", text: $viewModel.partOfPhoneNumber)
                            .font(.rubicRegularFont(size: 23))
                            .focused($focusedField, equals: .field)
                            .onAppear {
                                self.focusedField = .field
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(CustomColors.darkBlue)
                            .tint(CustomColors.darkBlue)
                            .padding(8)
                            .onChange(of: viewModel.partOfPhoneNumber) { newValue in
                                viewModel.handlePhoneNumberChange(to: newValue)
                            }
                    }
                    .padding(.leading, 4)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.interLightFont(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.red)
                        .padding(.top, 20)
                } else {
                    Text("send_verification_code".localized)
                        .font(.interLightFont(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(CustomColors.darkGray)
                        .padding(.top, 20)
                }
                
                Spacer()
                
                if viewModel.isLoading {
                    RotatingShapesLoader(animate: $isAnimating, color: .black)
                        .frame(maxWidth: 60)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                    Spacer()
                }
            }
            .padding(.horizontal, 30)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationBarBackButtonHidden(true)
            
            if showCountryPicker {
                VStack {
                    Spacer()
                    NavigationView {
                        List(CountryCode.allCases, id: \.self) { countryCode in
                            Button(action: {
                                viewModel.countryCode = countryCode
                                showCountryPicker = false
                            }) {
                                Text(countryCode.description)
                                    .foregroundColor(.black)
                            }
                        }
                        .navigationBarTitle("select_country_code".localized, displayMode: .inline)
                    }
                }
                .padding(.bottom)
                .onAppear {
                    focusedField = nil
                }
            }
        }
    }
}

struct NumberSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NumberSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
