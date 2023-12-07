//
//  CustomUnderlinedView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI

struct CustomUnderlinedView<Content: View>: View {
    var content: Content
    var color: Color = .gray
    var height: CGFloat = 2.0

    init(color: Color = .black, height: CGFloat = 2.0, @ViewBuilder content: () -> Content) {
        self.color = color
        self.height = height
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .zIndex(1)
            Rectangle()
                .frame(height: height)
                .foregroundColor(color)
        }
    }
}

struct UnderlineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            configuration
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
        }
    }
}
