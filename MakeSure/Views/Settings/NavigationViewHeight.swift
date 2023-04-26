//
//  NavigationViewHeight.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import SwiftUI

struct NavigationViewHeight: ViewModifier {
    var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
    }
}
