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
    
    @Published var contacts: [User] = []
    @Published var contactsM: [UserModel] = []
    @Published var sortBy: SortBy = .dateFollowed
    @Published var blockedUsers: [UserModel] = []
    @Published var tests: [Test] = []
    @Published var showCalendar = false
    @Published var showContactCalendar = false
    @Published var isShowLinkIsCopied = false
    @Published var myDates: [UUID : [Date]] = [:]
    @Published var myTests: [Date : [Test]] = [:]
    @Published var dateToStartInCalendar = Date()
    @Published var selectedDate: Date?
    @Published var meetings: [MeetingModel] = []
    @Published var isLoadingContacts: Bool = false
    @Published var isLoadingMeetings: Bool = false
    @Published var isLoadingBlacklist: Bool = false
    @Published var isAddingDate: Bool = false
    @Published var contactsImages: [UUID: UIImage] = [:]
    @Published var blacklistImages: [UUID: UIImage] = [:]
    @Published private(set) var hasLoadedContacts: Bool = false
    @Published private(set) var hasLoadedMeetings: Bool = false
    @Published private(set) var hasLoadedBlacklist: Bool = false
    @Published private(set) var hasAddedDate: Bool = false
    
    enum LoadImageFor {
        case blacklist
        case contact
    }
    
    var startDateInCalendar = Date.from(year: 2022, month: 1, day: 1)
    
    private let meetingsService = MeetingSupabaseService()
    private let userService = UserSupabaseService()
    let userId = UUID(uuidString: "3230f47c-e8ef-11ed-a05b-0242ac120003")!
    
    private var cancellables = Set<AnyCancellable>()
    
    let myUserId = UUID()
    
    init() {
        $sortBy
            .sink { [weak self] sortBy in
                self?.sortContacts(by: sortBy)
            }
            .store(in: &cancellables)
        
        $showCalendar.sink { [weak self] value in
            if !value {
                self?.dateToStartInCalendar = Date()
            }
        }.store(in: &cancellables)
        
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
        contacts.append(User(id: userId1, name: "Ryan", dates: [ myUserId : [Date.from(year: 2023, month: 4, day: 26)]], testsData: [Date.from(year: 2023, month: 4, day: 15) : tests], image: UIImage(named: "mockContactImage1")!, followedDate: Date.from(year: 2023, month: 3, day: 20)))
        contacts.append(User(id: userId2, name: "Joyce", dates: [ myUserId : [Date.from(year: 2023, month: 4, day: 22)]], testsData: [Date.from(year: 2023, month: 1, day: 13) : tests], image: UIImage(named: ("mockContactImage2"))!, followedDate: Date.from(year: 2023, month: 2, day: 16)))
        contacts.append(User(id: userId3, name: "Teresa", dates: [ myUserId : [Date.from(year: 2023, month: 4, day: 12)]], testsData: [Date.from(year: 2023, month: 4, day: 15) : tests.reversed()], image: UIImage(named: ("mockContactImage3"))!, followedDate: Date()))
        contacts.append(User(id: userId4, name: "Ryan", dates: [ myUserId : [Date.from(year: 2023, month: 4, day: 26)]], testsData: [Date.from(year: 2023, month: 4, day: 10) : tests], image: UIImage(named: ("mockContactImage4"))!, followedDate: Date()))
        contacts.append(User(id: userId5, name: "Ken", dates: [ myUserId : [Date.from(year: 2023, month: 2, day: 10)]], testsData: [Date.from(year: 2023, month: 4, day: 25) : tests], image: UIImage(named: ("mockContactImage5"))!, followedDate: Date()))
        
        myDates[userId1] = [Date.from(year: 2023, month: 4, day: 26)]
        myDates[userId2] = [Date.from(year: 2023, month: 3, day: 20)]
        myDates[userId3] = [Date.from(year: 2023, month: 4, day: 12)]
        myDates[userId4] = [Date.from(year: 2023, month: 4, day: 26)]
        myDates[userId5] = [Date.from(year: 2023, month: 2, day: 10)]
    }
    
    func fetchContacts() async {
        DispatchQueue.main.async {
            self.contactsM.removeAll()
            self.isLoadingContacts = true
        }
        
        var ids: [UUID] = []
        
        do {
            if let fetchedUser = try await userService.fetchUserById(id: userId) {
                if let contactsUsersIds = fetchedUser.contacts {
                    ids = Array(contactsUsersIds)
                }
                
                if ids.isEmpty {
                    DispatchQueue.main.async {
                        self.isLoadingContacts = false
                    }
                } else {
                    await withTaskGroup(of: UserModel?.self) { group in
                        for id in ids {
                            group.addTask {
                                do {
                                    if let user = try await self.userService.fetchUserById(id: id) {
                                        return user
                                    } else {
                                        return nil
                                    }
                                } catch {
                                    print("An error occurred with fetching a contact user: \(error)")
                                    return nil
                                }
                            }
                        }
                        
                        for await user in group {
                            if let user {
                                DispatchQueue.main.async {
                                    self.contactsM.append(user)
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.hasLoadedContacts = true
                        self.isLoadingContacts = false
                    }
                }
            } else {
                print("No contact user found with the specified ID")
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoadingContacts = false
            }
            print("Error loading contacts: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.isLoadingContacts = false
        }
    }
    
    func fetchMeetings() async {
        DispatchQueue.main.async {
            self.isLoadingMeetings = true
        }
        do {
            let fetchedMeetings = try await meetingsService.fetchMeetingsByUserId(userId: userId)
            DispatchQueue.main.async {
                self.meetings = fetchedMeetings
                self.updateMyDates()
                self.isLoadingMeetings = false
                self.hasLoadedMeetings = true
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoadingMeetings = false
            }
            print("Error loading meetings: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.isLoadingMeetings = false
        }
    }
    
    private func updateMyDates() {
        myDates.removeAll()
        
        for meeting in meetings {
            let partnerId = meeting.partnerId
            let meetingDate = meeting.date

            if myDates[partnerId] == nil {
                myDates[partnerId] = [meetingDate]
            } else {
                myDates[partnerId]?.append(meetingDate)
            }
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
    
    func contactsMetOn(date: Date) -> [UserModel] {
        var ids: [UUID] = []
        let calendar = Calendar.current
        myDates.forEach { _id, _dates in
            _dates.forEach { _date in
                if calendar.isDate(date, inSameDayAs: _date) {
                    ids.append(_id)
                }
            }
        }
        if !ids.isEmpty {
            return contactsM.filter { contact in
                if ids.contains(contact.id) {
                    return true
                }
                return false
            }
        }
        return []
    }
    
    func getLastDateWith(contact: UserModel) -> Date? {
        var dates: [Date] = []
        for dic in myDates {
            if dic.key == contact.id {
                dic.value.forEach { date in
                    dates.append(date)
                }
                break
            }
        }
        let sortDates = dates.sorted {
            $0 > $1
        }
        return sortDates.first
    }
    
    func sortContacts(by sortBy: SortBy) {
        switch sortBy {
        case .dateFollowed:
            contacts.sort { $0.followedDate > $1.followedDate }
        case .dateRecentMeetings:
            contactsM.sort {
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
    
    func unlockUser(_ user: User) {
        if let userIndex = blockedUsers.firstIndex(where: { $0.id == user.id }) {
            blockedUsers.remove(at: userIndex)
        }
        contacts.append(user)
    }
    
    func getTestsDates() -> [Date] {
        var dates: [Date] = []
        myTests.forEach { date, tests in
            dates.append(date)
        }
        return dates
    }
    
    /*func getLatestsTests(_ contact: UserModel) -> (date: Date, tests: [Test])? {
        let tests = contact.testsData.sorted { $0.0 < $1.0 }
        let latestTests = tests.first
        return (date: latestTests?.key, tests: latestTests?.value) as? (date: Date, tests: [Test])
    }
    
    func getMyLatestTestDate() -> Date? {
        let tests = getTestsDates()
        return tests.last
    }*/
    
    func shareMyLatestTest(with contactId: UUID, date: Date) {
        // implement sharing the last test
    }
    
    func addDate(_ date: Date, with contactId: UUID) async {
        DispatchQueue.main.async {
            self.isAddingDate = true
        }
        do {
            let model = MeetingModel(userId: userId, date: date, partnerId: contactId)
            try await meetingsService.create(item: model)
            DispatchQueue.main.async {
                self.hasAddedDate = true
                self.meetings.append(model)
                self.updateMyDates()
                self.selectedDate = nil
                self.showContactCalendar = false
                self.myDates.forEach { (key: UUID, value: [Date]) in
                    print(key)
                    value.forEach { date in
                        print(date)
                    }
                    print("\n")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isAddingDate = false
            }
            print("Error adding date: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.isAddingDate = false
        }
    }
    
    func addUserToBlacklist(id: UUID) {
        if let user = contacts.first(where: { $0.id == id }) {
            //blockedUsers.append(user)
        }
        if let userIndex = contacts.firstIndex(where: { $0.id == id }) {
            contacts.remove(at: userIndex)
        }
    }
    
    func deleteContact(id: UUID) {
        if let userIndex = contacts.firstIndex(where: { $0.id == id }) {
            contacts.remove(at: userIndex)
        }
    }
    
    func fetchBlacklist() async {
        DispatchQueue.main.async {
            self.blockedUsers.removeAll()
            self.isLoadingBlacklist = true
        }
        
        var ids: [UUID] = []
        
        do {
            if let fetchedUser = try await userService.fetchUserById(id: userId) {
                if let blacklistUsersIds = fetchedUser.blockedUsers {
                    ids = Array(blacklistUsersIds)
                }
                
                if ids.isEmpty {
                    DispatchQueue.main.async {
                        self.isLoadingBlacklist = false
                    }
                } else {
                    await withTaskGroup(of: UserModel?.self) { group in
                        for id in ids {
                            group.addTask {
                                do {
                                    if let user = try await self.userService.fetchUserById(id: id) {
                                        return user
                                    } else {
                                        return nil
                                    }
                                } catch {
                                    print("An error occurred with fetching a user: \(error)")
                                    return nil
                                }
                            }
                        }
                        
                        for await user in group {
                            if let user {
                                DispatchQueue.main.async {
                                    self.blockedUsers.append(user)
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.hasLoadedBlacklist = true
                        self.isLoadingBlacklist = false
                    }
                }
            } else {
                print("No user found with the specified ID")
            }
        } catch {
            print("An error occurred with fetching the user's tests: \(error)")
            DispatchQueue.main.async {
                self.isLoadingBlacklist = false
            }
        }
    }

    func loadImage(user: UserModel, for type: LoadImageFor) async {
        guard let urlStr = user.photoUrl, let url = URL(string: urlStr) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    switch type {
                    case .blacklist:
                        self.blacklistImages[user.id] = image
                    case .contact:
                        self.contactsImages[user.id] = image
                    }
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    func copyLinkBtnClicked() {
        isShowLinkIsCopied = true
        UIPasteboard.general.string = "My link: \(UUID().uuidString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isShowLinkIsCopied = false
        }
    }
    
}
