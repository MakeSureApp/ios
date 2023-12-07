//
//  ContactsViewModel.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI
import Combine

class ContactsViewModel: MainViewModel {
    
    @Published var contacts: [UserModel] = []
    @Published var sortBy: SortBy = .dateRecentMeetings
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
    @Published var isDeletingContact: Bool = false
    @Published var isUnlocingContact: Bool = false
    @Published var isAddingDate: Bool = false
    @Published var isAddingUserToContacts: Bool = false
    @Published var isAddingUserToBlacklist: Bool = false
    @Published var isSendingComplaint: Bool = false
    @Published var contactsImages: [UUID: UIImage] = [:]
    @Published var blacklistImages: [UUID: UIImage] = [:]
    @Published private(set) var hasLoadedContacts: Bool = false
    @Published private(set) var hasLoadedMeetings: Bool = false
    @Published private(set) var hasLoadedBlacklist: Bool = false
    @Published private(set) var hasDeletedContact: Bool = false
    @Published private(set) var hasUnlockedContact: Bool = false
    @Published private(set) var hasAddedDate: Bool = false
    @Published private(set) var hasAddedUserToBlacklist: Bool = false
    @Published private(set) var hasAddedUserToContacts: Bool = false
    @Published private(set) var hasSentComplaint: Bool = false
    
    private let blockedUsersQueue = DispatchQueue(label: "ru.turbopro.makesure.blockedUsersQueue", attributes: .concurrent)
    
    enum LoadImageFor {
        case blacklist
        case contact
    }
    
    var startDateInCalendar = Date.from(year: 2022, month: 1, day: 1)
    
    private let meetingsService = MeetingSupabaseService()
    private let userService = UserSupabaseService()
    private let complaintsService = SupportSupabaseService()
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        Task {
            await fetchContacts()
            await fetchBlacklist()
        }
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
    }
    
    func fetchContacts() async {
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.contacts.removeAll()
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
                                print("user \(user.name) == \(user.id)")
                                DispatchQueue.main.async {
                                    self.contacts.append(user)
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.hasLoadedContacts = true
                        self.isLoadingContacts = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.sortContacts(by: self.sortBy)
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
        guard let userId else {
            print("User ID not available!")
            return
        }
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
    
    func contactsMetOn(date: Date, withLimit: Int? = nil) -> [UserModel] {
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
            let filteredContacts = contacts.filter { contact in
                ids.contains(contact.id)
            }
            
            if let limit = withLimit {
                return Array(filteredContacts.prefix(limit))
            }
            return Array(filteredContacts)
        }
        return []
    }
    
    func getLastDateWith(contact: UserModel) -> Date? {
        let dates = myDates[contact.id] ?? []
        return dates.sorted(by: >).first
    }
    
    func sortContacts(by sortBy: SortBy) {
        let sortedContacts: [UserModel]
        switch sortBy {
        case .alphabetically:
            sortedContacts = contacts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            
        case .dateRecentMeetings:
            sortedContacts = contacts.sorted {
                let date1 = getLastDateWith(contact: $0)
                let date2 = getLastDateWith(contact: $1)
                return date1 ?? Date.distantPast > date2 ?? Date.distantPast
            }
        }
        contacts = sortedContacts
        print("end sorting")
    }
    
    enum SortBy: String {
        //case dateFollowed
        case alphabetically
        case dateRecentMeetings
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
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isAddingDate = true
        }
        do {
            let model = MeetingModel(userId: userId, date: date, partnerId: contactId)
            print("model = \(model)")
            try await meetingsService.create(item: model)
            DispatchQueue.main.async {
                self.hasAddedDate = true
                self.meetings.append(model)
                self.updateMyDates()
                self.selectedDate = nil
                self.showContactCalendar = false
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
    
    func addUserToBlacklist(id: UUID) async {
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isAddingUserToBlacklist = true
            self.hasAddedUserToContacts = false
        }
        do {
            var contactsCopy: [UUID] = contacts.map { $0.id }
            var blacklistUsersIds: [UUID] = blockedUsers.map { $0.id }
            if let userIndex = contacts.firstIndex(where: { $0.id == id }) {
                let userToBlock = contacts[userIndex]
                contactsCopy.remove(at: userIndex)
                blacklistUsersIds.append(id)

                try await userService.update(id: userId, fields: [
                    "contacts" : contactsCopy.isEmpty ? nil : contactsCopy,
                    "blocked_users" : blacklistUsersIds.isEmpty ? nil : blacklistUsersIds])

                DispatchQueue.main.async {
                    self.contacts.remove(at: userIndex)
                    if self.blockedUsers.first(where: { $0.id == id }) == nil {
                        self.blockedUsers.append(userToBlock)
                    }
                    self.isAddingUserToBlacklist = false
                    self.hasAddedUserToBlacklist = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isAddingUserToBlacklist = false
                }
                print("Error adding user to blacklist")
            }
        } catch {
            DispatchQueue.main.async {
                self.isAddingUserToBlacklist = false
            }
            print("Error adding user to blacklist: \(error.localizedDescription)")
        }
    }
    
    func addUserToContacts(user: UserModel) async {
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isAddingUserToContacts = true
        }
        do {
            var contactsCopy: [UUID] = contacts.map { $0.id }
            contactsCopy.append(user.id)
            try await userService.update(id: userId, fields: [
                "contacts" : contactsCopy.isEmpty ? nil : contactsCopy])
            DispatchQueue.main.async {
                self.contacts.append(user)
                self.isAddingUserToContacts = false
                self.hasAddedUserToContacts = true
            }
        } catch {
            print("Error adding user to contacts: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAddingUserToContacts = false
            }
        }
    }

    func unlockUser(_ id: UUID) async {
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isUnlocingContact = true
        }
        do {
            if !blockedUsers.isEmpty {
                var contactsCopy: [UUID] = contacts.map { $0.id }
                var blacklistUsersIds: [UUID] = blockedUsers.map { $0.id }
                if let userIndex = blacklistUsersIds.firstIndex(where: { $0 == id }) {
                    blacklistUsersIds.remove(at: userIndex)
                }
                contactsCopy.append(id)

                try await userService.update(id: userId, fields: [
                    "contacts" : contactsCopy.isEmpty ? nil : contactsCopy,
                    "blocked_users" : blacklistUsersIds.isEmpty ? nil : blacklistUsersIds])

                if let userIndex = blockedUsers.firstIndex(where: { $0.id == id }) {
                    let user = blockedUsers[userIndex]
                    DispatchQueue.main.async {
                        self.blockedUsers.remove(at: userIndex)
                        self.contacts.append(user)
                        self.isUnlocingContact = false
                        self.hasUnlockedContact = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isUnlocingContact = false
                    }
                }
            } else {
                print("Error unlocking contact from blacklist")
                DispatchQueue.main.async {
                    self.isUnlocingContact = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isUnlocingContact = false
            }
            print("Error unlocking contact from blacklist: \(error.localizedDescription)")
        }
    }
    
    func deleteContact(id: UUID) async {
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isDeletingContact = true
        }
        do {
            var contactsIds = contacts.map { $0.id }
            if !contactsIds.isEmpty {
                if let userIndex = contactsIds.firstIndex(where: { $0 == id }) {
                    contactsIds.remove(at: userIndex)
                }
                try await userService.update(id: userId, fields: [
                    "contacts" : contactsIds.isEmpty ? nil : contactsIds])
                DispatchQueue.main.async {
                    if let userIndex = self.contacts.firstIndex(where: { $0.id == id }) {
                        self.contacts.remove(at: userIndex)
                    }
                    self.isDeletingContact = false
                    self.hasDeletedContact = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isDeletingContact = false
            }
            print("Error deleting user from contacts: \(error.localizedDescription)")
        }
    }

    func fetchBlacklist() async {
        guard let userId else {
            print("User ID not available!")
            return
        }
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
                    for id in ids {
                        do {
                            if let user = try await userService.fetchUserById(id: id) {
                                DispatchQueue.main.async {
                                    self.blockedUsers.append(user)
                                }
                            }
                        } catch {
                            print("An error occurred with fetching a user: \(error)")
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
        switch type {
        case .blacklist:
            if blacklistImages[user.id] != nil {
                return
            }
        case .contact:
            if contactsImages[user.id] != nil {
                return
            }
        }
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
    
    func checkIfContactBlockedMe(user: UserModel) -> Bool {
        if (user.blockedUsers?.first(where: { $0 == userId })) != nil {
            return true
        }
        return false
    }
    
    func copyLinkBtnClicked() {
        isShowLinkIsCopied = true
        UIPasteboard.general.string = "My link: \(UUID().uuidString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isShowLinkIsCopied = false
        }
    }
    
    func checkIfUserAlreadyIsContact(id: UUID) -> Bool {
        if contacts.first(where: { $0.id == id }) != nil {
            return true
        } else {
            return false
        }
    }
    
    func checkIfUserBlocked(id: UUID) -> Bool {
        if blockedUsers.first(where: { $0.id == id }) != nil {
            return true
        } else {
            return false
        }
    }
    
    func sendComplaintReport(text: String, reportedUserId: UUID) async {
        guard let userId else {
            print("User ID not available!")
            return
        }
        DispatchQueue.main.async {
            self.isSendingComplaint = true
        }
        do {
            let model = Complaint(id: UUID(), createdAt: Date(), userId: reportedUserId, myUserId: userId, text: text)
            try await complaintsService.create(item: model)
            DispatchQueue.main.async {
                withAnimation {
                    self.isSendingComplaint = false
                    self.hasSentComplaint = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isSendingComplaint = false
            }
            print("Error sending complaint: \(error.localizedDescription)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.hasSentComplaint = false
            }
        }
    }
    
}
