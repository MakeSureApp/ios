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
                Text("We’re glad that you have joined us!")
                    .font(.rubicBoldFont(size: 23))
                    .fontWeight(.bold)
                
                Text("Please follow these rules")
                    .font(.interRegularFont(size: 17))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)

            // Terms of Use text
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Image("checkmark")
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("Be yourself.")
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("Make sure your photo and age are true to who you are.")
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image("checkmark")
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("Be honest.")
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("Do not attempt to falsify the results of express-tests. This may result in suspension or termination of account and criminal liability.")
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image("checkmark")
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("Be responsible.")
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("In case of a positive test, send a notification to all partners you may have infected. The app provides a simple and safe way to do it.")
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image("checkmark")
                            .padding(.leading, 0)
                            .padding(.bottom, -12)
                        Text("Be respectful.")
                            .font(.interSemiBoldFont(size: 17))
                            .fontWeight(.bold)
                            .padding([.top, .trailing])
                        Spacer()
                    }
                    Text("We does not tolerate harassment or bullying of any kind, and users who engage in these behaviors will have their account suspended.")
                        .font(.interRegularFont(size: 13))
                        .multilineTextAlignment(.leading)
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
