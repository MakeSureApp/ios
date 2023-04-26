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
                Text("Privacy & Safety")
                    .font(.poppinsBoldFont(size: 30))
                    .foregroundColor(.white)
                    .padding()
                Text("Coming soon")
                    .font(.poppinsMediumFont(size: 17))
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
