//
//  HomeViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI
import PhotosUI
import QRCodeGenerator

enum Category: String, CaseIterable {
    case health = "Health"
    case dates = "Dates"
    case selfDevelopment = "Self-development"
    
    var color: Color {
        switch self {
        case .health:
            return Color(red: 0, green: 23/255, blue: 119/255)
        case .dates:
            return Color(red: 105/255, green: 76/255, blue: 219/255)
        case .selfDevelopment:
            return Color(red: 112/255, green: 39/255, blue: 110/255)
        }
    }
}

struct TipsCategory: Hashable {
    let id: UUID
    let color: Color
    let name: String
    let nameRu: String
    
    var displayName: String {
        return appEnvironment.localizationManager.getLanguage() == .RU ? nameRu : name
    }
}

class HomeViewModel: NSObject, ObservableObject {
    
    @Published var mainViewModel: MainViewModel
    @Published var testsDone: Int = 0
    @Published var name: String = ""
    @Published var age: Int = 28
    @Published var birthdate: Date = Date()
    @Published var image: UIImage?
    @Published var tipCategories: [TipsCategory] = []
    @Published var selectedCategories: [TipsCategory] = []
    @Published var cards: [TipsModel] = []
    @Published var tipImages: [UUID: UIImage] = [:]
    @Published var qrCodeText: String?
    @Published var showPhoto = false
    @Published var showImagePhoto = false
    @Published var showMyQRCode = false
    @Published var showNotificationsView = false
    @Published var isLoadingUser: Bool = false
    @Published var isLoadingTests: Bool = false
    @Published var isLoadingImage: Bool = false
    @Published var isLoadingTips: Bool = false
    @Published var isUploadingImage: Bool = false
    @Published var isGeneratingQRCode: Bool = false
    @Published private(set) var hasLoadedUser: Bool = false
    @Published private(set) var hasLoadedTests: Bool = false
    @Published private(set) var hasLoadedImage: Bool = false
    @Published private(set) var hasLoadedTips: Bool = false
    @Published private(set) var loadingImageCount: Int = 0
    @Published private(set) var hasGeneratedQRCode: Bool = false
    
    private let userService = UserSupabaseService()
    private let testService = TestSupabaseService()
    private let tipsService = TipsSupabaseService()
    private let friendsLinksService = FriendsLinksSupabaseService()
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    func getUserData() async {
        guard let user = await mainViewModel.user else {
            print("User not available!")
            return
        }
        DispatchQueue.main.async {
            self.name = user.name
            self.birthdate = user.birthdate
            self.isLoadingUser = false
            self.hasLoadedUser = true
        }
    }
    
    func fetchUserData() async {
        guard let _ = await mainViewModel.user else {
            print("User not available!")
            return
        }
        DispatchQueue.main.async {
            self.isLoadingUser = true
        }
        do {
            if let user = try await userService.fetchUserById(id: mainViewModel.userId!) {
                DispatchQueue.main.async {
                    self.name = user.name
                    self.birthdate = user.birthdate
                    self.isLoadingUser = false
                    self.hasLoadedUser = true
                    self.mainViewModel.authService.authState = .isLoggedIn(user) // is not tested yet
                }
            } else {
                print("No user found with the specified ID")
                DispatchQueue.main.async {
                    self.isLoadingUser = false
                }
            }
        } catch {
            print("An error occurred with fetching the user!")
            DispatchQueue.main.async {
                self.isLoadingUser = false
            }
        }
    }
    
    func fetchTestsCount() async {
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isLoadingTests = true
        }
        do {
            let fetchedTests = try await testService.fetchById(columnName: "user_id", id: userId)
           
            DispatchQueue.main.async {
                self.testsDone = fetchedTests.filter { $0.date != nil }.count
                self.isLoadingTests = false
                self.hasLoadedTests = true
            }
        } catch {
            print("An error occurred with fetching the user's tests!")
            DispatchQueue.main.async {
                self.isLoadingTests = false
            }
        }
    }
    
    func fetchTips() async {
        DispatchQueue.main.async {
            self.isLoadingTips = true
        }
        do {
            let fetchedTips = try await tipsService.fetchAll()
            let uniqueCategories = Set(fetchedTips.map { BilingualCategory(english: $0.category, russian: $0.categoryRu) })
        
            let predefinedColors = [
                Color(red: 0, green: 23/255, blue: 119/255),
                Color(red: 105/255, green: 76/255, blue: 219/255),
                Color(red: 112/255, green: 39/255, blue: 110/255)
            ]

            let categories = uniqueCategories.enumerated().map { index, bilingualCategory -> TipsCategory in
                let color: Color
                if index < predefinedColors.count {
                    color = predefinedColors[index]
                } else {
                    color = Color(red: Double.random(in: 0...1),
                                  green: Double.random(in: 0...1),
                                  blue: Double.random(in: 0...1))
                }
                return TipsCategory(id: UUID(), color: color, name: bilingualCategory.english, nameRu: bilingualCategory.russian)
            }
            
            DispatchQueue.main.async {
                self.tipCategories = categories
                self.cards = fetchedTips
                self.isLoadingTips = false
                self.hasLoadedTips = true
            }
        } catch {
            print("An error occurred with fetching tips: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoadingTips = false
            }
        }
    }
    
    func loadImage() async {
        DispatchQueue.main.async {
            self.isLoadingImage = true
        }
        do {
            if let urlStr = await mainViewModel.user?.photoUrl, let url = URL(string: urlStr) {
                let (data, _) = try await URLSession.shared.data(from: url)
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                    self.isLoadingImage = false
                    self.hasLoadedImage = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingImage = false
                    self.hasLoadedImage = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoadingImage = false
            }
            print("Error loading user image: \(error.localizedDescription)")
        }
    }
    
    var filteredCards: [TipsModel] {
        if selectedCategories.isEmpty {
            return cards
        } else {
            return cards.filter { card in
                selectedCategories.contains(where: { $0.name == card.category })
            }
        }
    }
    
    func loadImageIfNeeded(for tip: TipsModel) {
        if tipImages[tip.id] == nil {
            Task {
                await loadImage(for: tip)
            }
        }
    }
    
    func loadImage(for tip: TipsModel) async {
        DispatchQueue.main.async {
            self.loadingImageCount += 1
        }
        do {
            if let url = URL(string: tip.imageUrl) {
                let (data, _) = try await URLSession.shared.data(from: url)
                DispatchQueue.main.async {
                    self.tipImages[tip.id] = UIImage(data: data)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.tipImages[tip.id] = nil
            }
            print("Error loading user image: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.loadingImageCount -= 1
        }
    }
    
    func createFriendLink() async {
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isGeneratingQRCode = true
        }
        do {
            let fetchedLinks = try await friendsLinksService.fetchLinksByUserId(userId: userId)
            var id = UUID()
            if fetchedLinks.isEmpty {
                let createdAt = Date()
                let model = FriendLinkModel(id: id, createdAt: createdAt, userId: userId)
                try await friendsLinksService.create(item: model)
            } else {
                if let linkId = fetchedLinks.first?.id {
                    id = linkId
                }
            }
            let text = id.uuidString
           
            DispatchQueue.main.async {
                self.qrCodeText = text
                self.isGeneratingQRCode = false
                self.hasGeneratedQRCode = true
            }
        } catch {
            DispatchQueue.main.async {
                self.isGeneratingQRCode = false
            }
            print("Error generating qrcode: \(error.localizedDescription)")
        }
    }
    
    func openTipsDetails(_ urlStr: String) {
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
    
    func uploadUserImage() async {
        guard let image, let userId = await mainViewModel.userId else { return }
        var photoUrl: String? = nil
        DispatchQueue.main.async {
            self.isUploadingImage = true
        }
        do {
            if let uploadedURL = try await userService.uploadUserImage(image, userId: userId) {
                photoUrl = uploadedURL
            }
        } catch {
            print("An error occurred while uploading image: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isUploadingImage = false
                self.image = nil
            }
            return
        }
        do {
            try await userService.update(id: userId, fields: ["photo_URL": photoUrl])
        } catch {
            print("An error occurred while updating user image: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.image = nil
            }
        }
        DispatchQueue.main.async {
            self.isUploadingImage = false
        }
    }
    
}

extension HomeViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    func requestPhoto() {
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
        actionSheet.addAction(UIAlertAction(title: "take_a_photo".localized, style: .default, handler: { _ in
            self.showImagePicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "choose_from_library".localized, style: .default, handler: { _ in
            self.showPHPicker()
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
                    }
                    Task {
                        await self.uploadUserImage()
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
            Task {
                await uploadUserImage()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
