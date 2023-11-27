//
//  RoundedGradientButton.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI

struct RoundedGradientButton: View {
    let text: String
    var isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.rubicBoldFont(size: 21))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .padding(.vertical, 2)
                .foregroundColor(isEnabled ? .white : .gray)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isEnabled ? CustomColors.mainGradient : CustomColors.whiteGradient)
                        .shadow(color: .gray, radius: 2, x: 0, y: 1)
                )
        }
        .disabled(!isEnabled)
        .padding(.bottom)
    }
}
