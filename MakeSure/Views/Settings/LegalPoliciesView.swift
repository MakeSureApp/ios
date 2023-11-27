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
                Text("legal_policies_section".localized)
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

struct LegalPoliciesView_Previews: PreviewProvider {
    static var previews: some View {
        LegalPoliciesView()
    }
}
