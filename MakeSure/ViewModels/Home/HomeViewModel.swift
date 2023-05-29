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
    let name: String
    let color: Color
}

class HomeViewModel: NSObject, ObservableObject {
    
    @Published var testsDone: Int = 0
    @Published var name: String = "JANE"
    @Published var age: Int = 28
    @Published var image: UIImage?
    @Published var tipCategories: [TipsCategory] = []
    @Published var selectedCategories: [TipsCategory] = []
    @Published var cards: [TipsModel] = []
    @Published var tipImages: [UUID: UIImage] = [:]
    @Published var qrCodeText: String?
//     [
//        Card(title: "Safe tips for Speed Dating", description: "How to talk to a partner about tests?", image: "mockTipsImage", category: .dates, url: "https://example.com/1"),
//        Card(title: "Keep safe & keep romantic", description: nil, image: "mockTipsImage2", category: .selfDevelopment, url: ""),
//        Card(title: "Sex education: what you need to know", description: nil, image: "mockTipsImage", category: .health, url: "https://example.com/3")
//    ]
    @Published var showPhotoMenu = false
    @Published var showImagePhoto = false
    @Published var showMyQRCode = false
    @Published var user: UserModel?
    @Published var isLoadingUser: Bool = false
    @Published var isLoadingTests: Bool = false
    @Published var isLoadingImage: Bool = false
    @Published var isLoadingTips: Bool = false
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
    private let friensLinksService = FriendsLinksSupabaseService()
    let userId = UUID(uuidString: "79295454-e8f0-11ed-a05b-0242ac120003")!
    
    func fetchUserData() async {
        DispatchQueue.main.async {
            self.isLoadingUser = true
        }
        do {
            if let user = try await userService.fetchUserById(id: userId) {
                DispatchQueue.main.async {
                    self.user = user
                    self.isLoadingUser = false
                    self.hasLoadedUser = true
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
        DispatchQueue.main.async {
            self.isLoadingTests = true
        }
        do {
            let fetchedTests = try await testService.fetchByUserId(columnName: "user_id", userId: userId)
           
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
            let uniqueCategories = Set(fetchedTips.map { $0.category })
        
            let predefinedColors = [
                Color(red: 0, green: 23/255, blue: 119/255),
                Color(red: 105/255, green: 76/255, blue: 219/255),
                Color(red: 112/255, green: 39/255, blue: 110/255)
            ]

            let categories = uniqueCategories.enumerated().map { index, categoryName -> TipsCategory in
                let color: Color
                if index < predefinedColors.count {
                    color = predefinedColors[index]
                } else {
                    color = Color(red: Double.random(in: 0...1),
                                  green: Double.random(in: 0...1),
                                  blue: Double.random(in: 0...1))
                }
                return TipsCategory(id: UUID(), name: categoryName, color: color)
            }
            
            DispatchQueue.main.async {
                self.tipCategories = categories
                self.cards = fetchedTips
                self.isLoadingTips = false
                self.hasLoadedTips = true
            }
        } catch {
            print("An error occurred with fetching tips!")
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
            if let urlStr = user?.photoUrl, let url = URL(string: urlStr) {
                let (data, _) = try await URLSession.shared.data(from: url)
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                    self.isLoadingImage = false
                    self.hasLoadedImage = true
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
        DispatchQueue.main.async {
            self.isGeneratingQRCode = true
        }
        do {
            let fetchedLinks = try await friensLinksService.fetchLinksByUserId(userId: userId)
            var id = UUID()
            if fetchedLinks.isEmpty {
                let createdAt = Date()
                let model = FriendLinkModel(id: id, createdAt: createdAt, userId: userId)
                try await friensLinksService.create(item: model)
            } else {
                if let linkId = fetchedLinks.first?.id{
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
    
    func orderNewBoxClicked() {
        print("Order new box")
    }
    
    func openTipsDetails(_ urlStr: String) {
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
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
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
