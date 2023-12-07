//
//  TermsOfUseView.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

struct TermsOfUseSignUpView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("welcome_message".localized)
                    .font(.rubicBoldFont(size: 24))
                    .foregroundStyle(CustomColors.darkBlue)
                
                Text("rules_heading".localized)
                    .font(.rubicRegularFont(size: 14))
                    .foregroundStyle(CustomColors.darkGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)

            // Terms of Use text
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("rule_1".localized)
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("rule_2".localized)
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(CustomColors.darkGray)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("rule_3".localized)
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("rule_4".localized)
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(CustomColors.darkGray)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("rule_5".localized)
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("rule_6".localized)
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(CustomColors.darkGray)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("rule_7".localized)
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("rule_8".localized)
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(CustomColors.darkGray)
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 30)

            Spacer()
        }
    }
}

struct TermsOfUseSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfUseSignUpView(viewModel: RegistrationViewModel(authService: AuthService()))
    }
}
