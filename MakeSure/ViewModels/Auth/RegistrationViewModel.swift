//
//  AuthViewModel.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

enum Gender {
    case male
    case female
}

enum RegistrationSteps: Int, CaseIterable {
    case initial
    case phoneNumber
    case code
    case email
    case verifyEmail
    case firstName
    case birthday
    case gender
    case profilePhoto
    case agreement
    case congratulations
    case final
}

enum RegistrationProgressBarSteps: Int, CaseIterable {
    case phoneNumber = 1
    case email
    case firstName
    case birthday
    case gender
    case profilePhoto
}

class RegistrationViewModel: NSObject, ObservableObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    @ObservedObject var authService: AuthService
    
    @Published var currentStep: RegistrationSteps = .phoneNumber
    
    @Published var partOfPhoneNumber = ""
    @Published var countryCode: CountryCode = .RU
    @Published var codeFields = Array<String>(repeating: "", count: 6)
    @Published var codeSent = false
    @Published var codeValidated = false
    @Published var canSendCode = false
    
    @Published var email = ""
    @Published var emailValidated = false
    @Published var emailVerified = false
    
    @Published var firstNameValidated = false
    @Published var firstName = ""
    
    @Published var birthdayFields = Array<String>(repeating: "", count: 8)
    @Published var birthdayValidated = false
    
    @Published var gender: Gender? = nil
    
    var genderValidated: Bool {
        switch gender {
        case .none:
            return false
        case .some(_):
            return true
        }
    }
    @Published var image: UIImage?
    @Published var photoAdded = false
    @Published var termsOfUseAccepted = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var phoneNumber: String {
        return countryCode.rawValue + partOfPhoneNumber
    }
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .phoneNumber:
            return canSendCode
        case .code:
            return codeValidated
        case .email:
            return emailValidated // or skip
        case .firstName:
            return firstNameValidated
        case .birthday:
            return birthdayValidated
        case .gender:
            return genderValidated
        case .profilePhoto:
            return photoAdded // or skip
        default:
            return true
        }
    }
    
    var currentProgressBarStep: RegistrationProgressBarSteps {
        switch currentStep {
        case .phoneNumber, .code:
            return .phoneNumber
        case .email, .verifyEmail:
            return .email
        case .firstName:
            return .firstName
        case .birthday:
            return .birthday
        case .gender:
            return .gender
        case .profilePhoto:
            return .profilePhoto
        default:
            return .phoneNumber
        }
    }
    
    var isProgresBarShow: Bool {
        if currentStep == .agreement || currentStep == .congratulations {
            return false
        }
        return true
    }
    
    var isSkipButtonShow: Bool {
        if currentStep == .email || currentStep == .verifyEmail || currentStep == .profilePhoto {
            return true
        }
        return false
    }
    
    init(authService: AuthService) {
        self.authService = authService
        for family in UIFont.familyNames {
            print(family)
            for names in UIFont.fontNames(forFamilyName: family){
                print("== \(names)")
            }
        }
    }
    
    func moveToNextStep() {
        currentStep = currentStep.next()
    }
    
    func moveToPreviousStep() {
        if currentStep == .verifyEmail {
            currentStep = currentStep.previous().previous()
        } else {
            currentStep = currentStep.previous()
        }
    }
    
    func skipPage() {
        if currentStep == .email {
            currentStep = currentStep.next().next()
        } else if currentStep == .verifyEmail || currentStep == .profilePhoto {
            currentStep = currentStep.next()
        }
    }
    
    func getFullPhoneNumber() -> String {
        return countryCode.rawValue + phoneNumber
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
    
    func validateEmail(_ email: String) {
        if email.isValidEmail {
            emailValidated = true
        } else {
            emailValidated = false
        }
    }
    
    //    func validateAndProceed(email: String) {
    //        // Validate the email
    //        if isValidEmail(email) {
    //            self.emailValidated = true
    //            // Send a verification link to the email
    //            // After sending the link, update the emailVerified to true
    //            self.emailVerified = true
    //        } else {
    //            self.emailValidated = false
    //        }
    //    }
    
    func validateName(_ name: String) {
        if name.isValidFirstName {
            firstNameValidated = true
        } else {
            firstNameValidated = false
        }
    }
    
    
    func validateBirtday(_ birthday: Array<String>) {
        let strBirthday = birthday.joined()
        if strBirthday.isValidBirthdayDate {
            birthdayValidated = true
        } else {
            birthdayValidated = false
        }
    }
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.pickPhoto()
                case .denied, .restricted:
                    self.showPermissionDeniedAlert()
                case .limited:
                    // You can decide how to handle this case, e.g., show a different alert or proceed with the limited access
                    self.pickPhoto()
                case .notDetermined:
                    // This case should not be reached, as the requestAuthorization completion handler is only called after the user has made a decision
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Access Denied", message: "Please allow access to your photo library in your device's settings to pick a photo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.last?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func pickPhoto() {
        let actionSheet = UIAlertController(title: "Select Photo", message: "Choose a photo from your library or take a new one", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.showPHPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.showImagePicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        UIApplication.shared.windows.last?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func showPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        UIApplication.shared.windows.last?.rootViewController?.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.image = image
                        self.photoAdded = true
                    }
                }
            }
        }
    }
    
    func showImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        UIApplication.shared.windows.last?.rootViewController?.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            self.image = image
            photoAdded = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func removeImage() {
        image = nil
        photoAdded = false
    }
    
    func completeRegistration() {
        authService.authState = .isLoggedIn
        resetAllData()
    }
    
    static func ==(lhs: RegistrationViewModel, rhs: RegistrationViewModel) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func resetAllData() {
        currentStep = .phoneNumber
        firstNameValidated = false
        countryCode = .RU
        partOfPhoneNumber = ""
        codeFields = Array<String>(repeating: "", count: 6)
        codeValidated = false
        codeSent = false
        email = ""
        emailValidated = false
        firstName = ""
        firstNameValidated = false
        birthdayFields = Array<String>(repeating: "", count: 8)
        birthdayValidated = false
        gender = nil
        photoAdded = false
    }
    
}

