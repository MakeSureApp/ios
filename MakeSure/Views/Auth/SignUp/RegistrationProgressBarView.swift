//
//  RegistrationProgressBarView.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import Foundation
import SwiftUI

struct RegistrationProgressBarView: View {
    var progress: Int
    var countParts: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(CustomColors.mainGradient)
                    .frame(width: CGFloat(progress) / CGFloat(countParts) * geometry.size.width, height: 4)
            }
        }
        .frame(height: 4)
    }
}

