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
import SupabaseStorage

enum Gender: String {
    case male
    case female
}

enum RegistrationSteps: Int, CaseIterable {
    case initial
    case phoneNumber
    case code
    case email
    // case verifyEmail
    case firstName
    case birthday
//    case gender
//    case profilePhoto
    case linkApple
    case agreement
    case congratulations
    case final
}

enum RegistrationProgressBarSteps: Int, CaseIterable {
    case phoneNumber = 1
    case email
    case firstName
    case birthday
//    case gender
//    case profilePhoto
    case linkApple
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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var email = ""
    @Published var emailValidated = false
    @Published var emailVerified = false
    
    @Published var firstNameValidated = false
    @Published var firstName = ""
    
    @Published var birthdayFields = Array<String>(repeating: "", count: 8)
    @Published var birthdayValidated = false
    
    @Published var gender: Gender? = nil
    
    enum AppleLinkError {
        case isAlreadyRegistered
        case other
    }
    
    @Published var userIdFromApple: UUID?
    @Published var appleIdLinked = false
    @Published var isLoadingUser: Bool = false
    @Published var isLinkingApple: Bool = false
    @Published var linkingError: AppleLinkError? {
        didSet {
            if linkingError != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.linkingError = nil
                }
            }
        }
    }
    
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
    private var validationCancellable: AnyCancellable?
    
    private let signInApple = AppleSignIn()
    private let authSupabaseService = AuthSupabaseService()
    private let userSupabaseService = UserSupabaseService()
    
    @Published var isLoggingInWithApple: Bool = false
    
    var phoneNumber: String {
        return countryCode.rawValue + partOfPhoneNumber
    }
    
    var birthdayDate: Date? {
        let dateStr = birthdayFields.joined().dateStringFromDateInput
        return dateStr.dateFromString
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
//        case .gender:
//            return genderValidated
//        case .profilePhoto:
//            return photoAdded // or skip
        case .linkApple:
            return appleIdLinked // or skip
        default:
            return true
        }
    }
    
    var currentProgressBarStep: RegistrationProgressBarSteps {
        switch currentStep {
        case .phoneNumber, .code:
            return .phoneNumber
        case .email:
            return .email
        case .firstName:
            return .firstName
        case .birthday:
            return .birthday
//        case .gender:
//            return .gender
//        case .profilePhoto:
//            return .profilePhoto
        case .linkApple:
            return .linkApple
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
        if currentStep == .email || currentStep == .linkApple {
            return true
        }
        return false
    }
    
    init(authService: AuthService) {
        self.authService = authService
        //        for family in UIFont.familyNames {
        //            print(family)
        //            for names in UIFont.fontNames(forFamilyName: family){
        //                print("== \(names)")
        //            }
        //        }
    }
    
    func moveToNextStep() {
        currentStep = currentStep.next()
        if currentStep == .code {
            //authService.sendSMS(to: phoneNumber)
        }
    }
    
    func moveToPreviousStep() {
        currentStep = currentStep.previous()
    }
    
    func skipPage() {
        if currentStep == .email || currentStep == .linkApple {
            currentStep = currentStep.next()
        }
    }
    
    func getFullPhoneNumber() -> String {
        return countryCode.rawValue + phoneNumber
    }
    
    func handlePhoneNumberChange(to newValue: String) {
        validationCancellable?.cancel()
        
        validationCancellable = Just(newValue)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { _ in
                Task {
                    await self.validatePhoneNumber()
                }
            }
    }
    
    private func validatePhoneNumber() async {
        self.canSendCode = false
        guard phoneNumber.isPhoneNumber else {
            self.errorMessage = nil
            return
        }
        self.isLoading = true
        do {
            let fetchedUser = try await userSupabaseService.fetchUserByPhone(phone: phoneNumber)
            if fetchedUser == nil {
                self.canSendCode = true
                self.errorMessage = nil
            } else {
                self.errorMessage = "user_with_number_exists".localized
            }
        } catch {
            print("An error occurred while searching user: \(error)")
            self.errorMessage = "check_internet_connection".localized
        }
        self.isLoading = false
    }
    
    func validateCode(_ code: Array<String>) {
        let strCode = code.joined()
        // Validate the phone code
        if strCode.count == 6 {//&& authService.isCodeValid(strCode) {
            codeValidated = true
        } else {
            codeValidated = false
        }
    }
    
    func resendCode() {
        //authService.sendSMS(to: phoneNumber)
    }
    
    func validateEmail() {
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
    
    func validateName() {
        if firstName.isValidFirstName {
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
        let alert = UIAlertController(title: "access_denied".localized, message: "allow_photo_access".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel_button".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "settings".localized, style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.last?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func pickPhoto() {
        let actionSheet = UIAlertController(title: "select_photo".localized, message: "choose_photo_description".localized, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "choose_from_library".localized, style: .default, handler: { _ in
            self.showPHPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "take_a_photo".localized, style: .default, handler: { _ in
            self.showImagePicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "cancel_button".localized, style: .cancel, handler: nil))
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
    
    func registerWithApple() {
        signInApple.signInWithApple { result in
            switch result {
            case .success(let result):
                self.authWithApple(result: result)
            case .failure(let error):
                print("Error with signing in with apple id: \(error.localizedDescription)")
            }
        }
    }
    
    private func authWithApple(result: SignInAppleResult) {
        DispatchQueue.main.async {
            self.isLinkingApple = true
        }
        Task {
            do {
                if let id = try await authSupabaseService.authWithApple(idToken: result.idToken, nonce: result.nonce) {
                    DispatchQueue.main.async {
                        print("user apple id = \(id)")
                        self.isLinkingApple = false
                        self.userIdFromApple = id
                    }
                    self.checkUserInSupabase(id: id)
                } else {
                    DispatchQueue.main.async {
                        self.isLinkingApple = false
                        self.linkingError = .isAlreadyRegistered
                        print("Error with signing in to supabase with apple id")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLinkingApple = false
                    self.linkingError = .other
                    print("Error with signing in to supabase with apple id : \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkUserInSupabase(id: UUID) {
        DispatchQueue.main.async {
            self.isLoadingUser = true
        }
        Task {
            do {
                if let _ = try await userSupabaseService.fetchUserById(id: id) {
                    print("User already exists, proceed to login.")
                    DispatchQueue.main.async {
                        self.isLoadingUser = false
                        self.linkingError = .isAlreadyRegistered
                    }
                } else {
                    print("No user found with the specified ID, continue with registration.")
                    DispatchQueue.main.async {
                        self.isLoadingUser = false
                        self.appleIdLinked = true
                    }
                }
            } catch {
                print("An error occurred with fetching the user!")
                DispatchQueue.main.async {
                    self.isLoadingUser = false
                    self.linkingError = .other
                }
            }
        }
    }
    
    func completeRegistration() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        let id = (userIdFromApple != nil && appleIdLinked) ? userIdFromApple! : UUID()
        var photoUrl: String? = nil
        if let selectedImage = image {
            do {
                if let uploadedURL = try await userSupabaseService.uploadUserImage(selectedImage, userId: id) {
                    photoUrl = uploadedURL
                }
            } catch {
                print("An error occurred while uploading image: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.currentStep = .agreement
                }
                return
            }
        }
        let user = UserModel(id: id, name: firstName, birthdate: birthdayDate!, sex: gender!.rawValue, phone: phoneNumber, email: email.isEmpty ? nil : email, photoUrl: photoUrl)
        do {
            try await userSupabaseService.create(item: user)
            DispatchQueue.main.async {
                self.authService.authState = .isLoggedIn(user)
                self.resetAllData()
                self.isLoading = false
            }
        } catch {
            print("An error occurred while creating user: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func resetAllData() {
        currentStep = .phoneNumber
        firstNameValidated = false
        countryCode = .RU
        partOfPhoneNumber = ""
        codeFields = Array<String>(repeating: "", count: 6)
        canSendCode = false
        codeValidated = false
        codeSent = false
        errorMessage = nil
        isLoading = false
        email = ""
        emailValidated = false
        firstName = ""
        firstNameValidated = false
        birthdayFields = Array<String>(repeating: "", count: 8)
        birthdayValidated = false
        gender = nil
        photoAdded = false
        linkingError = nil
        appleIdLinked = false
        userIdFromApple = nil
    }
    
}

