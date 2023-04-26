//
//  SettingsViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import Foundation
import SwiftUI

enum AvailableLanguages: String, CaseIterable {
    case RU = "Russian"
    case EN = "English"
    
    var short: String {
        switch self {
        case .RU:
            return "RU"
        case .EN:
            return "EN"
        }
    }
}

enum SettingsPhoneNumberSteps: Int, CaseIterable {
    case initial
    case phoneNumber
    case code
    case congratulations
    case final
}

enum SettingsEmailSteps: Int, CaseIterable {
    case initial
    case email
    case verifyEmail
    case congratulations
    case final
}

class SettingsViewModel: ObservableObject {
    
    @ObservedObject var authService: AuthService
    @Published var notificationsEnabled = true
    @Published var selectedLanguage: AvailableLanguages = .EN
    @Published var emailAddress = "example@email.com"
    @Published var isEmail = true
    @Published var isVerified = true
    @Published var mobileNumber = "+1 (555) 123-4567"
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func signOutBtnClicked() {
        authService.authState = .isLoggedOut
    }
    
    //MARK: Changing phone number
    @Published var phoneCurrentStep: SettingsPhoneNumberSteps = .phoneNumber
    @Published var partOfPhoneNumber = ""
    @Published var countryCode: CountryCode = .RU
    @Published var codeFields = Array<String>(repeating: "", count: 6)
    @Published var codeSent = false
    @Published var codeValidated = false
    @Published var canSendCode = false
    
    var phoneNumber: String {
        return countryCode.rawValue + partOfPhoneNumber
    }
    
    var phoneCanProceedToNextStep: Bool {
        switch phoneCurrentStep {
        case .phoneNumber:
            return canSendCode
        case .code:
            return codeValidated
        default:
            return true
        }
    }
    
    func phoneMoveToNextStep() {
        phoneCurrentStep = phoneCurrentStep.next()
    }
    
    func phoneMoveToPreviousStep() {
        phoneCurrentStep = phoneCurrentStep.previous()
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
    
    func phoneResetAllData() {
        phoneCurrentStep = .phoneNumber
        partOfPhoneNumber = ""
        countryCode = .RU
        codeFields = Array<String>(repeating: "", count: 6)
        canSendCode = false
        codeValidated = false
        codeSent = false
    }
    
    func completeChangingPhoneNumber() {
        phoneResetAllData()
    }
    
    //MARK: Adding/Changing Email
    @Published var changingEmail = ""
    @Published var emailValidated = false
    @Published var emailVerified = false
    @Published var emailCurrentStep: SettingsEmailSteps = .email
    
    var emailCanProceedToNextStep: Bool {
        switch emailCurrentStep {
        case .email:
            return emailValidated
        default:
            return true
        }
    }
    
    func emailMoveToNextStep() {
        emailCurrentStep = emailCurrentStep.next()
    }
    
    func emailMoveToPreviousStep() {
        if emailCurrentStep == .verifyEmail {
            emailCurrentStep = emailCurrentStep.previous().previous()
        } else {
            emailCurrentStep = emailCurrentStep.previous()
        }
    }
    
    func validateEmail(_ email: String) {
        if email.isValidEmail {
            emailValidated = true
        } else {
            emailValidated = false
        }
    }
    
    func completeChangingEmail() {
        emailResetAllData()
    }
    
    func emailResetAllData() {
        emailCurrentStep = .email
        changingEmail = ""
        emailValidated = false
    }
    
}
