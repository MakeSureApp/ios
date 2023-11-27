//
//  NotificationsViewModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 19.06.2023.
//

import Foundation

class NotificationsViewModel: ObservableObject {
    
    @Published var groupedNotifications: [(key: String, value: [NotificationModel])] = []
    @Published var notifications: [NotificationModel] = [] {
        didSet {
            groupNotificationsByDay()
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
        guard let userId = await mainViewModel.userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            let notificationsData = try await notificationsSupabaseService.fetchNotificationsByUserId(userId: userId)
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
    
    private func groupNotificationsByDay() {
        DispatchQueue.main.async {
            let calendar = Calendar.current
            self.groupedNotifications = Dictionary(grouping: self.notifications) { notification in
                // Extract just the year, month, and day components to group by
                let components = calendar.dateComponents([.year, .month, .day], from: notification.createdAt)
                return calendar.date(from: components) ?? notification.createdAt
            }
            .map { (date, notifications) in
                let formattedDate = self.formatDateForGrouping(date)
                return (key: formattedDate, value: notifications.sorted { $0.createdAt > $1.createdAt })
            }
            .sorted { $0.key < $1.key }
        }
    }
    
    private func formatDateForGrouping(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "today_label".localized
        } else if Calendar.current.isDateInYesterday(date) {
            return "yesterday_label".localized
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE - dd.MM"
            return formatter.string(from: date)
        }
    }
    
    private func subscribeToNotificationChanges() {
        //        notificationsSupabaseService.subscribeToUserIdChanges(userId: mainViewModel.userId) { [weak self] newNotifications in
        //            DispatchQueue.main.async {
        //                if let newNotifications {
        //                    self?.notifications = newNotifications
        //                }
        //            }
        //        }
    }
    
    deinit {
        //notificationsSupabaseService.unsubscribeFromUserIdChanges(userId: mainViewModel.userId)
    }
}
