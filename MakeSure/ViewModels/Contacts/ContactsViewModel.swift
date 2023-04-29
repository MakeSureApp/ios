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
    @Published var showContactCalendar = false
    @Published var isShowLinkIsCopied = false
    @Published var myDates: [UUID : Date] = [:]
    @Published var myTests: [Date : [Test]] = [:]
    
    var startDateInCalendar = Date.from(year: 2022, month: 1, day: 1)
    
    private var cancellables = Set<AnyCancellable>()
    
    let myUserId = UUID()
    
    init() {
        $sortBy
            .sink { [weak self] sortBy in
                self?.sortContacts(by: sortBy)
            }
            .store(in: &cancellables)
        
        tests.append(Test(id: UUID(), name: "HIV"))
        tests.append(Test(id: UUID(), name: "Syphilis"))
        tests.append(Test(id: UUID(), name: "Chlamydia"))
        tests.append(Test(id: UUID(), name: "Gonorrhea"))
        tests.append(Test(id: UUID(), name: "Hepatite B"))
        tests.append(Test(id: UUID(), name: "HPV"))
        
        myTests[Date.from(year: 2023, month: 3, day: 23)] = tests
        myTests[Date.from(year: 2023, month: 3, day: 14)] = tests
        myTests[Date.from(year: 2023, month: 4, day: 28)] = tests
        myTests[Date.from(year: 2023, month: 4, day: 5)] = tests
        myTests[Date.from(year: 2023, month: 2, day: 20)] = tests
        
        let userId1 = UUID()
        let userId2 = UUID()
        let userId3 = UUID()
        let userId4 = UUID()
        let userId5 = UUID()
        contacts.append(Contact(id: userId1, name: "Ryan", dates: [ myUserId : Date.from(year: 2023, month: 4, day: 26)], testsData: [Date.from(year: 2023, month: 4, day: 15) : tests], image: Image("mockContactImage1"), followedDate: Date.from(year: 2023, month: 3, day: 20)))
        contacts.append(Contact(id: userId2, name: "Joyce", dates: [ myUserId : Date.from(year: 2023, month: 4, day: 22)], testsData: [Date.from(year: 2023, month: 1, day: 13) : tests], image: Image("mockContactImage2"), followedDate: Date.from(year: 2023, month: 2, day: 16)))
        contacts.append(Contact(id: userId3, name: "Teresa", dates: [ myUserId : Date.from(year: 2023, month: 4, day: 12)], testsData: [Date.from(year: 2023, month: 4, day: 15) : tests.reversed()], image: Image("mockContactImage3"), followedDate: Date()))
        contacts.append(Contact(id: userId4, name: "Ryan", dates: [ myUserId : Date.from(year: 2023, month: 4, day: 26)], testsData: [Date.from(year: 2023, month: 4, day: 10) : tests], image: Image("mockContactImage4"), followedDate: Date()))
        contacts.append(Contact(id: userId5, name: "Ken", dates: [ myUserId : Date.from(year: 2023, month: 2, day: 10)], testsData: [Date.from(year: 2023, month: 4, day: 25) : tests], image: Image("mockContactImage5"), followedDate: Date()))
        
        myDates[userId1] = Date.from(year: 2023, month: 4, day: 26)
        myDates[userId2] = Date.from(year: 2023, month: 3, day: 20)
        myDates[userId3] = Date.from(year: 2023, month: 4, day: 12)
        myDates[userId4] = Date.from(year: 2023, month: 4, day: 26)
        myDates[userId5] = Date.from(year: 2023, month: 2, day: 10)
        
        for i in 1...20 {
            blockedUsers.append(BlockedUser(id: UUID(), username: "steven_crash", name: "Steven \(i)", imageName: "mockBlackListUserImage"))
        }
    }
    
    func getMetDateString(_ metDate: Date?) -> String? {
        guard let metDate else { return nil }
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: metDate, to: now)
        let daysSinceMet = components.day ?? 0
        let monthsSinceMet = components.month ?? 0
        let yearsSinceMet = components.year ?? 0
        
        switch (daysSinceMet, monthsSinceMet, yearsSinceMet) {
        case (0, 0, 0):
            return "Met today"
        case (1, 0, 0):
            return "Met yesterday"
        case (2...6, 0, 0):
            return "Met \(daysSinceMet) days ago"
        case (7...13, 0, 0):
            return "Met a week ago"
        case (14...20, 0, 0):
            return "Met two weeks ago"
        case (21...27, 0, 0):
            return "Met three weeks ago"
        case (_, 1, 0):
            return "Met a month ago"
        case (_, 2..<12, 0):
            return "Met \(monthsSinceMet) months ago"
        case (_, _, 1):
            return "Met a year ago"
        case (_, _, _):
            return "Met \(yearsSinceMet) years ago"
        }
    }
    
    func metDateColor(date: Date) -> Color {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: now)
        let daysSinceMet = components.day ?? 0

        if daysSinceMet <= 2 {
            return Color(red: 1, green: 64.0 / 255.0, blue: 156.0 / 255.0, opacity: 0.84)
        } else if daysSinceMet <= 7 {
            return Color(red: 247.0 / 255.0, green: 213.0 / 255.0, blue: 1)
        } else if daysSinceMet <= 30 {
            return Color(red: 204.0 / 255.0, green: 199.0 / 255.0, blue: 1)
        } else {
            return Color(red: 181.0 / 255.0, green: 228.0 / 255.0, blue: 1)
        }
    }
    
    func contactsMetOn(date: Date) -> [Contact] {
        var ids: [UUID] = []
        let calendar = Calendar.current
        myDates.forEach { _id, _date in
            if calendar.isDate(date, inSameDayAs: _date) {
                ids.append(_id)
            }
        }
        if !ids.isEmpty {
            return contacts.filter { contact in
                if ids.contains(contact.id) {
                    return true
                }
                return false
            }
        }
        return []
    }
    
    func getLastDateWith(contact: Contact) -> Date? {
        var dates: [Date] = []
        myDates.forEach { dic in
            if dic.key == contact.id {
                dates.append(dic.value)
            }
        }
        let sortDates = dates.sorted {
            $0 > $1
        }
        return sortDates.last
    }
    
    func sortContacts(by sortBy: SortBy) {
        switch sortBy {
        case .dateFollowed:
            contacts.sort { $0.followedDate > $1.followedDate }
        case .dateRecentMeetings:
            contacts.sort {
                if let date1 = getLastDateWith(contact: $0), let date2 = getLastDateWith(contact: $1) {
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
        myTests.forEach { date, tests in
            dates.append(date)
        }
        return dates
    }
    
    func getLatestsTests(_ contact: Contact) -> (date: Date, tests: [Test])? {
        let tests = contact.testsData.sorted{ $0.0 < $1.0 }
        let latestTests = tests.first
        return (date: latestTests?.key, tests: latestTests?.value) as? (date: Date, tests: [Test])
    }
    
    func addDate(_ date: Date, with contactId: UUID) {
        myDates[contactId] = date
    }
    
    func copyLinkBtnClicked() {
        isShowLinkIsCopied = true
        UIPasteboard.general.string = "My link: \(UUID().uuidString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isShowLinkIsCopied = false
        }
    }
    
}
