//
//  LoginViewModel.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import Combine
import SwiftUI
import AuthenticationServices

enum LoginSteps: Int, CaseIterable {
    case initial
    case phoneNumber
    case code
    case final
}

class LoginViewModel: NSObject, ObservableObject {
    
    @ObservedObject var authService: AuthService
    
    enum InitialNavigation {
        case main
        case login
    }
    
    @Published var navState: InitialNavigation = .main
    
    @Published var currentStep: LoginSteps = .phoneNumber
    
    @Published var partOfPhoneNumber = ""
    @Published var countryCode: CountryCode = .RU
    @Published var codeFields = Array<String>(repeating: "", count: 6)
    @Published var codeSent = false
    @Published var codeValidated = false
    @Published var canSendCode = false
    
    var phoneNumber: String {
        return countryCode.rawValue + partOfPhoneNumber
    }
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .phoneNumber:
            return canSendCode
        case .code:
            return codeValidated
        default:
            return true
        }
    }
    
    func moveToNextStep() {
        currentStep = currentStep.next()
    }
    
    func moveToPreviousStep() {
        currentStep = currentStep.previous()
    }
    
    func validatePhoneNumber() {
        if phoneNumber.isPhoneNumber {
            canSendCode = true
        } else {
            canSendCode = false
        }
    }
    
    func validateCode(_ code: Array<String>) {
        let strCode = code.joined()
        // Validate the phone code
        if strCode.count == 6 && isValidCode(strCode) {
            codeValidated = true
        } else {
            codeValidated = false
        }
    }

    private func isValidCode(_ code: String) -> Bool {
        // Implement code validation logic
        return true
    }
    
    func resendCode() {
        
    }
    
    func handleSignInWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func resetAllData() {
        currentStep = .phoneNumber
        partOfPhoneNumber = ""
        countryCode = .RU
        codeFields = Array<String>(repeating: "", count: 6)
        canSendCode = false
        codeValidated = false
        codeSent = false
    }
    
    func completeAuthorization() {
        authService.authState = .isLoggedIn
        resetAllData()
    }
    
    func openTermsOfUse() {
        print("terms of use")
    }
    
    func openPrivacyPolicy() {
        print("privacy policy")
    }
    
}

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Handle successful sign-in with Apple ID
            authService.authState = .isLoggedIn
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle errors
    }
}

extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
