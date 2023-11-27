//
//  PositiveTestWarningView.swift
//  MakeSure
//
//  Created by Macbook Pro on 18.09.2023.
//

import SwiftUI

struct PositiveTestWarningView: View {
    var body: some View {
        Text("positive_result_message".localized)
            .font(.rubicBoldFont(size: 34))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
}

struct PositiveTestWarningView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestWarningView()
    }
}
