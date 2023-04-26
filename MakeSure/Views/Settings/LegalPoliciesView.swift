//
//  LegalPoliciesView.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct LegalPoliciesView: View {
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack(spacing: 30) {
                Text("Legal & Policies")
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

struct LegalPoliciesView_Previews: PreviewProvider {
    static var previews: some View {
        LegalPoliciesView()
    }
}
