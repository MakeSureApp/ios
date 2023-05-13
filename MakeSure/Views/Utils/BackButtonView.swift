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
                Text("go_back_button".localized)
                    .font(.rubicRegularFont(size: 24))
                    .foregroundColor(color)
            }
            .foregroundColor(color)
        }
    }
}
