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
    
    enum LoginError {
        case isNotRegistered
        case other
    }
    
    @Published var navState: InitialNavigation = .main
    
    @Published var currentStep: LoginSteps = .phoneNumber
    
    @Published var partOfPhoneNumber = ""
    @Published var countryCode: CountryCode = .RU
    @Published var codeFields = Array<String>(repeating: "", count: 6)
    @Published var codeSent = false
    @Published var codeValidated = false
    @Published var canSendCode = false
    
    private let signInApple = AppleSignIn()
    private let authSupabaseService = AuthSupabaseService()
    private let userServiceSupabase = UserSupabaseService()
    
    @Published var isLoggingInWithApple: Bool = false
    @Published var loginError: LoginError? {
        didSet {
            if loginError != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.loginError = nil
                }
            }
        }
    }
    @Published var isLoadingUser: Bool = false
    
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
        // todo: fetch userdata
        DispatchQueue.main.async {
            //self.authService.authState = .isLoggedIn
            self.resetAllData()
        }
    }
    
    func openTermsOfUse() {
        print("terms of use")
    }
    
    func openPrivacyPolicy() {
        print("privacy policy")
    }
    
    // MARK: Apple Sign In
    
    func signInWithApple() {
        signInApple.signInWithApple { result in
            switch result {
            case .success(let result):
                print(result)
                self.authWithApple(result: result)
            case .failure(let error):
                print("Error with signing in with apple id: \(error.localizedDescription)")
            }
        }
    }
        
    private func authWithApple(result: SignInAppleResult) {
        DispatchQueue.main.async {
            self.isLoggingInWithApple = true
        }
        Task {
            do {
                if let id = try await authSupabaseService.authWithApple(idToken: result.idToken, nonce: result.nonce) {
                    DispatchQueue.main.async {
                        self.isLoggingInWithApple = false
                        print("Successfully logged In with Apple. User id = \(id)")
                        self.fetchUserData(id: id)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoggingInWithApple = false
                        self.loginError = .isNotRegistered
                        print("Error with signing in to supabase with apple id")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoggingInWithApple = false
                    self.loginError = .other
                    print("Error with signing in to supabase with apple id : \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchUserData(id: UUID) {
        DispatchQueue.main.async {
            self.isLoadingUser = true
        }
        Task {
            do {
                if let user = try await userServiceSupabase.fetchUserById(id: id) {
                    DispatchQueue.main.async {
                        self.authService.authState = .isLoggedIn(user)
                    }
                } else {
                    print("No user found with the specified ID")
                    DispatchQueue.main.async {
                        self.isLoadingUser = false
                        self.loginError = .isNotRegistered
                    }
                }
            } catch {
                print("An error occurred with fetching the user!")
                DispatchQueue.main.async {
                    self.isLoadingUser = false
                    self.loginError = .other
                }
            }
        }
    }
    
}
