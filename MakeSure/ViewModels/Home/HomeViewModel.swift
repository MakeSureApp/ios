//
//  HomeViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import Foundation
import SwiftUI
import PhotosUI

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

class HomeViewModel: NSObject, ObservableObject {
    
    @Published var testsDone: Int = 5
    @Published var name: String = "JANE"
    @Published var age: Int = 28
    @Published var image = UIImage(named: "mockPhotoImageHome")
    @Published var tipCategories: [Category] = [.health, .dates, .selfDevelopment]
    @Published var selectedCategories: [Category] = []
    @Published var cards: [Card] = [
        Card(title: "Safe tips for Speed Dating", description: "How to talk to a partner about tests?", image: "mockTipsImage", category: .dates, url: "https://example.com/1"),
        Card(title: "Keep safe & keep romantic", description: nil, image: "mockTipsImage2", category: .selfDevelopment, url: ""),
        Card(title: "Sex education: what you need to know", description: nil, image: "mockTipsImage", category: .health, url: "https://example.com/3")
    ]
    @Published var showPhotoMenu = false
    @Published var showImagePhoto = false
    @Published var showMyQRCode = false
    
    var filteredCards: [Card] {
        if selectedCategories.isEmpty {
            return cards
        } else {
            return cards.filter { selectedCategories.contains($0.category) }
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
