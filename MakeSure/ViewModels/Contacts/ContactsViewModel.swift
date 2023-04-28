//
//  ContactsViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI
import Combine

class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [Contact] = []
    @Published var sortBy: SortBy = .dateFollowed
    @Published var blockedUsers: [BlockedUser] = []
    @Published var tests: [Test] = []
    @Published var showCalendar = false
    @Published var isShowLinkIsCopied = false
    
    var startDateInCalendar = Date.from(year: 2022, month: 1, day: 1) ?? Date()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $sortBy
            .sink { [weak self] sortBy in
                self?.sortContacts(by: sortBy)
            }
            .store(in: &cancellables)
        
        contacts.append(Contact(id: UUID(), name: "Ryan", metDate: Date.from(year: 2023, month: 4, day: 26), image: Image("mockContactImage1"), followedDate: Date.from(year: 2023, month: 3, day: 20) ?? Date()))
        contacts.append(Contact(id: UUID(), name: "Joyce", metDate: Date.from(year: 2023, month: 4, day: 22), image: Image("mockContactImage2"), followedDate: Date.from(year: 2023, month: 2, day: 16) ?? Date()))
        contacts.append(Contact(id: UUID(), name: "Teresa", metDate: Date.from(year: 2023, month: 4, day: 12), image: Image("mockContactImage3"), followedDate: Date()))
        contacts.append(Contact(id: UUID(), name: "Ryan", metDate: Date.from(year: 2023, month: 4, day: 26), image: Image("mockContactImage4"), followedDate: Date()))
        contacts.append(Contact(id: UUID(), name: "Ken", metDate: Date.from(year: 2023, month: 2, day: 10), image: Image("mockContactImage5"), followedDate: Date()))
        
        tests.append(Test(id: UUID(), name: "HIV", date: Date.from(year: 2023, month: 2, day: 23) ?? Date()))
        tests.append(Test(id: UUID(), name: "Syphilis", date: Date.from(year: 2023, month: 1, day: 13) ?? Date()))
        tests.append(Test(id: UUID(), name: "Chlamydia", date: Date.from(year: 2023, month: 4, day: 15) ?? Date()))
        tests.append(Test(id: UUID(), name: "Gonorrhea", date: Date.from(year: 2023, month: 4, day: 10) ?? Date()))
        tests.append(Test(id: UUID(), name: "Hepatite B", date: Date.from(year: 2023, month: 2, day: 3) ?? Date()))
        tests.append(Test(id: UUID(), name: "HPV", date: Date.from(year: 2023, month: 4, day: 25) ?? Date()))
        
        for i in 1...20 {
            blockedUsers.append(BlockedUser(id: UUID(), username: "steven_crash", name: "Steven \(i)", imageName: "mockBlackListUserImage"))
        }
    }
    
    func contactsMetOn(date: Date) -> [Contact] {
        let calendar = Calendar.current
        return contacts.filter { contact in
            guard let metDate = contact.metDate else { return false }
            return calendar.isDate(metDate, inSameDayAs: date)
        }
    }
    
    func sortContacts(by sortBy: SortBy) {
        switch sortBy {
        case .dateFollowed:
            contacts.sort { $0.followedDate > $1.followedDate }
        case .dateRecentMeetings:
            contacts.sort {
                if let date1 = $0.metDate, let date2 = $1.metDate {
                    return date1 > date2
                }
                return false
            }
        }
    }
    
    enum SortBy: String {
        case dateFollowed
        case dateRecentMeetings
    }
    
    func unlockUser(_ user: BlockedUser) {
        if let userIndex = blockedUsers.firstIndex(where: { $0.id == user.id }) {
            blockedUsers.remove(at: userIndex)
        }
    }
    
    func getTestsDates() -> [Date] {
        var dates: [Date] = []
        tests.forEach { test in
            dates.append(test.date)
        }
        return dates
    }
    
    func copyLinkBtnClicked() {
        isShowLinkIsCopied = true
        UIPasteboard.general.string = "My link: \(UUID().uuidString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isShowLinkIsCopied = false
        }
    }
    
}
