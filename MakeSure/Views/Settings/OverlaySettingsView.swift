//
//  OverlaySettingsView.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import Foundation
import SwiftUI

struct OverlaySettingsView<Content: View>: ViewModifier {
    @Binding var isShowing: Bool
    let settingsView: (Binding<Bool>) -> Content

    func body(content: Self.Content) -> some View {
        ZStack {
            content

            if isShowing {
                Color.clear
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }

                settingsView($isShowing)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

extension View {
    func overlaySettingsView<Content: View>(isShowing: Binding<Bool>, content: @escaping (Binding<Bool>) -> Content) -> some View {
        modifier(OverlaySettingsView(isShowing: isShowing, settingsView: content))
    }
}
