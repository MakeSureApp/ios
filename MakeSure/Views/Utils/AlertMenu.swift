//
//  AlertMenu.swift
//  MakeSure
//
//  Created by Macbook Pro on 27.11.2023.
//

import SwiftUI

struct AlertMenu: View {
    let alertText: String
    let actionBtnText: String
    let onCancel: () -> Void
    let onAction: () -> Void
    
    var body: some View {
        VStack {
            Text(alertText)
                .font(.montserratBoldFont(size: 18))
                .minimumScaleFactor(0.6)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
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
                   onAction()
                } label: {
                    Text(actionBtnText)
                        .font(.montserratBoldFont(size: 14))
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color(red: 1, green: 50.0/255.0, blue: 38.0/255.0))
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(CustomColors.thirdGradient)
        .cornerRadius(16)
        .frame(maxWidth: 300)
    }
}

//#Preview {
//    AlertMenu()
//}
