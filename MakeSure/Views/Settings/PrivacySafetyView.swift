//
//  PrivacySafetyView.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct PrivacySafetyView: View {
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                Text("privacy_safety_section".localized)
                    .font(.montserratBoldFont(size: 30))
                    .foregroundColor(.white)
                    .padding()
                Text("coming_soon".localized)
                    .font(.montserratMediumFont(size: 17))
                    .foregroundColor(.white)
            }
        }
    }
}

struct PrivacySafetyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySafetyView()
    }
}
