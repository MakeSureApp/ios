//
//  SettingsViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/25/23.
//

import Combine
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
    
    var key: String {
        switch self {
        case .RU:
            return "ru-RU"
        case .EN:
            return "en"
        }
    }
    
    var text: String {
        switch self {
        case .RU:
            return "language_russian".localized
        case .EN:
            return "language_english".localized
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
    //case verifyEmail
    case congratulations
    case final
}

class SettingsViewModel: ObservableObject {
    
    @Published var mainViewModel: MainViewModel
    @Published var notificationsEnabled = true
    @Published var selectedLanguage = appEnvironment.localizationManager.getLanguage() {
        didSet {
            localizationManager.setLanguage(selectedLanguage.key)
        }
    }
    @Published var emailAddress = ""
    @Published var isEmail = false
    @Published var isEmailUpdated = false
    @Published var isVerified = true
    @Published var mobileNumber = ""
    @Published var errorMessage: String?
    
    private let localizationManager = appEnvironment.localizationManager
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    func signOutBtnClicked() {
        mainViewModel.authService.authState = .isLoggedOut
    }
    
    //MARK: Changing phone number
    @Published var phoneCurrentStep: SettingsPhoneNumberSteps = .phoneNumber
    @Published var partOfPhoneNumber = ""
    @Published var countryCode: CountryCode = .RU
    @Published var codeFields = Array<String>(repeating: "", count: 6)
    @Published var codeSent = false
    @Published var codeValidated = false
    @Published var canSendCode = false
    @Published var isLoading: Bool = false
    @Published var isPhoneUpdated = false
    @Published var isCheckingNumber = false
    
    private var validationPhoneCancellable: AnyCancellable?
    
    private let userSupabaseService = UserSupabaseService()
    
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
        if phoneCurrentStep == .code {
            Task {
                await completeChangingPhoneNumber()
                DispatchQueue.main.async {
                    if self.isPhoneUpdated {
                        self.phoneCurrentStep = self.phoneCurrentStep.next()
                    }
                }
            }
        } else {
            phoneCurrentStep = phoneCurrentStep.next()
        }
    }
    
    func phoneMoveToPreviousStep() {
        phoneCurrentStep = phoneCurrentStep.previous()
    }
    
    func handlePhoneNumberChange(to newValue: String) {
        validationPhoneCancellable?.cancel()
        
        validationPhoneCancellable = Just(newValue)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { _ in
                Task {
                    await self.validatePhoneNumber()
                }
            }
    }
    
    private func validatePhoneNumber() async {
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        
        guard phoneNumber.isPhoneNumber else {
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
            return
        }
        DispatchQueue.main.async {
            self.isCheckingNumber = true
            self.canSendCode = false
        }
        do {
            let fetchedUser = try await userSupabaseService.fetchUserByPhone(phone: phoneNumber)
            DispatchQueue.main.async {
                if fetchedUser == nil {
                    self.canSendCode = true
                    self.errorMessage = nil
                } else if let fetchedUser, fetchedUser.id == userId {
                    self.errorMessage = "current_number".localized
                } else {
                    self.errorMessage = "user_with_number_exists".localized
                }
                self.isCheckingNumber = false
            }
        } catch {
            DispatchQueue.main.async {
                print("An error occurred while searching user: \(error)")
                self.errorMessage = "check_internet_connection".localized
                self.isCheckingNumber = false
            }
        }
    }
    
    func validateCode(_ code: Array<String>) {
        let strCode = code.joined()
        // Validate the phone code
        if strCode.count == 6 {//&& authService.isCodeValid(strCode)
            codeValidated = true
        } else {
            codeValidated = false
        }
    }
    
    func resendCode() {
        //authService.sendSMS(to: phoneNumber)
    }
    
    func phoneResetAllData() {
        DispatchQueue.main.async {
            self.phoneCurrentStep = .phoneNumber
            self.partOfPhoneNumber = ""
            self.countryCode = .RU
            self.codeFields = Array<String>(repeating: "", count: 6)
            self.canSendCode = false
            self.codeValidated = false
            self.codeSent = false
            self.isLoading = false
            self.isPhoneUpdated = false
            self.errorMessage = nil
        }
    }
    
    func completeChangingPhoneNumber() async {
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            try await userSupabaseService.update(id: userId, fields: ["phone": phoneNumber])
            DispatchQueue.main.async {
                self.isLoading = false
                self.isPhoneUpdated = true
            }
        } catch {
            print("An error occurred while updating phone number: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    //MARK: Adding/Changing Email
    @Published var changingEmail = ""
    @Published var emailValidated = false
    @Published var emailVerified = false
    @Published var emailCurrentStep: SettingsEmailSteps = .email
    @Published var isCheckingEmail = false
    
    private var validationEmailCancellable: AnyCancellable?
    
    var emailCanProceedToNextStep: Bool {
        switch emailCurrentStep {
        case .email:
            return emailValidated
        default:
            return true
        }
    }
    
    func emailMoveToNextStep() {
        if emailCurrentStep == .email {
            Task {
                await completeChangingEmail()
                DispatchQueue.main.async {
                    if self.isEmailUpdated {
                        self.emailCurrentStep = self.emailCurrentStep.next()
                    }
                }
            }
        } else {
            emailCurrentStep = emailCurrentStep.next()
        }
    }
    
    func emailMoveToPreviousStep() {
        emailCurrentStep = emailCurrentStep.previous()
    }
    
    func handleEmailChange(to newValue: String) {
        validationEmailCancellable?.cancel()
        
        validationEmailCancellable = Just(newValue)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { _ in
                Task {
                    await self.validateEmail()
                }
            }
    }
    
    private func validateEmail() async {
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        guard changingEmail.isValidEmail else {
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
            return
        }
        DispatchQueue.main.async {
            self.isCheckingEmail = true
            self.emailValidated = false
        }
        do {
            let fetchedUser = try await userSupabaseService.fetchUserByEmail(email: changingEmail)
            DispatchQueue.main.async {
                if fetchedUser == nil {
                    self.emailValidated = true
                    self.errorMessage = nil
                } else if let fetchedUser, fetchedUser.id == userId {
                    self.errorMessage = "current_email".localized
                } else {
                    self.errorMessage = "user_with_email_exists".localized
                }
                self.isCheckingEmail = false
            }
        } catch {
            DispatchQueue.main.async {
                print("An error occurred while searching user: \(error)")
                self.errorMessage = "check_internet_connection".localized
                self.isCheckingEmail = false
            }
        }
    }
    
    func completeChangingEmail() async {
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            try await userSupabaseService.update(id: userId, fields: ["email": changingEmail])
            DispatchQueue.main.async {
                self.isLoading = false
                self.isEmailUpdated = true
            }
        } catch {
            print("An error occurred while updating email: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func emailResetAllData() {
        DispatchQueue.main.async {
            self.emailCurrentStep = .email
            self.changingEmail = ""
            self.emailValidated = false
            self.isEmailUpdated = false
            self.isLoading = false
            self.errorMessage = nil
        }
    }
    
    func toggleNotifications() {
        if !notificationsEnabled {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            
        }
    }
    
}
