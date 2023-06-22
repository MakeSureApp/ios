//
//  AppleSignInButton.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI
import AuthenticationServices

//struct AppleSignInButton: UIViewRepresentable {
//    @ObservedObject var loginViewModel: LoginViewModel
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
//        let button = ASAuthorizationAppleIDButton()
//        button.addTarget(context.coordinator, action: #selector(Coordinator.signInTapped), for: .touchUpInside)
//        return button
//    }
//
//    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
//
//    class Coordinator: NSObject {
//        let parent: AppleSignInButton
//
//        init(_ parent: AppleSignInButton) {
//            self.parent = parent
//        }
//        @objc func signInTapped() {
//            parent.loginViewModel.handleSignInWithApple()
//        }
//    }
//}
