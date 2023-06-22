//
//  ScannerViewModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.05.2023.
//

import Foundation
import UIKit

class ScannerViewModel: MainViewModel {
    
    @Published var isPresentingScanner = true
    @Published var scannedCode: String?
    @Published var isLoading: Bool = false
    @Published private(set) var hasLoaded: Bool = false
    @Published var searchedUser: UserModel?
    @Published var userImage: UIImage?
    @Published var isShowUser = false
    @Published var errorMessage: String?
    
    private let friendsLinksService = FriendsLinksSupabaseService()
    private let userService = UserSupabaseService()
    
    func searchUser(id: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                let uuid = UUID(uuidString: id) ?? UUID()
                print("id ==== \(uuid.uuidString.lowercased())")
                let fetchedFriendLinksModels = try await friendsLinksService.fetchLinksById(id: uuid)
                if let friendLinkModel = fetchedFriendLinksModels.first {
                    let fetchedUser = try await userService.fetchUserById(id: friendLinkModel.userId)
                    if let fetchedUser {
                        await loadImage(urlStr: fetchedUser.photoUrl)
                        try await friendsLinksService.delete(id: friendLinkModel.id)
                        DispatchQueue.main.async {
                            self.searchedUser = fetchedUser
                            self.isLoading = false
                            self.hasLoaded = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.searchedUser = nil
                            self.isLoading = false
                            self.errorMessage = "Unable to load user" //add localization
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "User not found" //add localization
                    }
                }
            } catch {
                print("An error occurred while searching user: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "check_internet_connection".localized
                }
            }
        }
    }
    
    func searchGlobalUser(id: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                let uuid = UUID(uuidString: id) ?? UUID()
                if let user = try await userService.fetchUserById(id: uuid) {
                    await loadImage(urlStr: user.photoUrl)
                    DispatchQueue.main.async {
                        self.searchedUser = user
                        self.isLoading = false
                        self.hasLoaded = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.searchedUser = nil
                        self.isLoading = false
                        self.errorMessage = "User not found" //add localization
                    }
                }
            } catch {
                print("An error occurred while searching user: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "check_internet_connection".localized
                }
            }
        }
    }
    
    private func loadImage(urlStr: String?) async {
        guard let urlStr, let url = URL(string: urlStr) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.userImage = image
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    func resetData() {
        scannedCode = nil
        searchedUser = nil
        userImage = nil
        errorMessage = nil
        hasLoaded = false
        isShowUser = false
        isPresentingScanner = true
    }
}
