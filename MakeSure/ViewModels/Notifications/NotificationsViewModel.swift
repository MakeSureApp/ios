//
//  NotificationsViewModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 19.06.2023.
//

import Foundation

class NotificationsViewModel: ObservableObject {
    
    @Published var groupedNotifications: [(key: Date, value: [NotificationModel])] = []
    @Published var notifications: [NotificationModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.groupedNotifications = Dictionary(grouping: self.notifications) { $0.createdAt }
                    .mapValues { values in
                        values.sorted { $0.createdAt > $1.createdAt }
                    }
                    .sorted { $0.key > $1.key }
            }
        }
    }
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasLoaded: Bool = false
    
    @Published var mainViewModel: MainViewModel
    
    private let notificationsSupabaseService = NotificationsSupabaseService()
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        Task {
            await fetchNotifications()
        }
        subscribeToNotificationChanges()
    }
    
    func fetchNotifications() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            let notificationsData = try await notificationsSupabaseService.fetchNotificationsByUserId(userId: mainViewModel.userId)
            DispatchQueue.main.async {
                self.notifications = notificationsData
                print(notificationsData)
                self.isLoading = false
                self.hasLoaded = true
            }
        } catch {
            print("An error occurred with fetching notifications!")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func subscribeToNotificationChanges() {
        notificationsSupabaseService.subscribeToUserIdChanges(userId: mainViewModel.userId) { [weak self] newNotifications in
            DispatchQueue.main.async {
                if let newNotifications {
                    self?.notifications = newNotifications
                }
            }
        }
    }
    
    deinit {
        notificationsSupabaseService.unsubscribeFromUserIdChanges(userId: mainViewModel.userId)
    }
}
