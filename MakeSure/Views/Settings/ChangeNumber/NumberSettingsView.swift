//
//  AddEmailView.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct NumberSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var showCountryPicker = false
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        ZStack {
            VStack {
                // Title
                Text("my_number_is".localized)
                    .font(.rubicBoldFont(size: 44))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // Country code and phone number input
                HStack {
                    CustomUnderlinedView {
                        Button(action: {
                            showCountryPicker.toggle()
                        }) {
                            HStack {
                                Text(viewModel.countryCode.description)
                                    .font(.rubicRegularFont(size: 24))
                                    .foregroundColor(.black)
                                
                                Image(systemName: "arrowtriangle.down.fill")
                                    .resizable()
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
                            .font(.rubicRegularFont(size: 24))
                            .focused($focusedField, equals: .field)
                            .onAppear {
                                self.focusedField = .field
                            }
                            .keyboardType(.numberPad)
                            .foregroundColor(.black)
                            .padding(8)
                            .onChange(of: viewModel.partOfPhoneNumber) { _ in
                                viewModel.validatePhoneNumber()
                            }
                    }
                    .padding(.leading, 4)
                }
                .padding(.horizontal)
                
                Text("send_verification_code".localized)
                    .font(.interLightFont(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(CustomColors.darkGray)
                    .padding()
                    .padding(.top, 20)
                
                Spacer()
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
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

struct NumberSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NumberSettingsView()
            .environmentObject(SettingsViewModel(mainViewModel: MainViewModel()))
    }
}
