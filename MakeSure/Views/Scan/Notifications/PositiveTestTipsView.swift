//
//  PositiveTestTipsView.swift
//  MakeSure
//
//  Created by Macbook Pro on 18.09.2023.
//

import SwiftUI

struct PositiveTestTipsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("tips_heading".localized)
                    .font(.rubicBoldFont(size: 34))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
    }
}

struct PositiveTestTipsView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestTipsView()
    }
}
