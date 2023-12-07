//
//  BackButton.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI

struct BackButtonView: View {
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .frame(width: 14, height: 24)
                    .foregroundStyle(color)
                    .padding(.trailing, 4)
                Text("go_back_button".localized)
                    .font(.rubicRegularFont(size: 22))
                    .foregroundStyle(color)
            }
            .foregroundColor(color)
        }
    }
}

#Preview {
    BackButtonView(color: CustomColors.darkBlue) {
        
    }
}
