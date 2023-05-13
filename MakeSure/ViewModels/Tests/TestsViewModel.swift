//
//  TestsViewModel.swift
//  MakeSure
//
//  Created by andreydem on 5/2/23.
//

import Foundation

class TestsViewModel: ObservableObject {
    
    @Published var tests: [TestModel] = []
    @Published var contactTests: [TestModel] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingContactTests: Bool = false
    @Published var showTestsCalendar = false
    @Published var dateToStartInCalendar = Date()
    @Published private(set) var hasLoaded: Bool = false
    @Published private(set) var hasLoadedContactTests: Bool = false
    @Published private(set) var lastTests: [TestModel] = []
    @Published private(set) var contactLastTests: [TestModel] = []
    private(set) lazy var groupedTests: [Date: [TestModel]] = [:]
    
    private var testService = TestSupabaseService()
    let userId = UUID(uuidString: "79295454-e8f0-11ed-a05b-0242ac120003")!
    
    enum LatestTestFor {
        case myself
        case contact
    }
    
    func fetchTests() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                let fetchedTests = try await testService.fetchByUserId(columnName: "user_id", userId: userId)
                DispatchQueue.main.async {
                    self.tests = fetchedTests
                    self.isLoading = false
                    self.hasLoaded = true
                    self.groupTests(for: .myself)
                }
            } catch {
                print("An error occurred while fetching tests: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func groupTests(for type: LatestTestFor) {
        switch type {
        case .myself:
            let testsWithDates = tests.filter { $0.date != nil }
            let grouped = Dictionary(grouping: testsWithDates) { (test: TestModel) -> Date in
                return test.date!.startOfDay
            }
            groupedTests = grouped
            let latestDate = tests.compactMap { $0.date }.sorted().last
            if let latestDate {
                lastTests = tests.filter { $0.date?.startOfDay == latestDate.startOfDay }
            }
//            if let index = groupedTests.firstIndex(where: { $0.key.startOfDay == lastTests.first?.date?.startOfDay }) {
//                groupedTests.remove(at: index)
//            }
        case .contact:
            let latestDate = contactTests.compactMap { $0.date }.sorted().last
            if let latestDate = latestDate {
                contactLastTests = contactTests.filter { $0.date?.startOfDay == latestDate.startOfDay }
            }
        }
    }
    
    func orderNewBoxClicked() {
        print("Order new box")
    }
    
    func uniqueDateRanges() -> [String] {
        var sortedDates = Array(groupedTests.keys.compactMap { $0 }).sorted()
        sortedDates.removeLast()
        sortedDates = sortedDates.reversed()
        var dateRanges: [String] = []
        for date in sortedDates {
            let rangeString = dateGroupString(date: date)
            if !dateRanges.contains(rangeString) {
                dateRanges.append(rangeString)
            }
        }
        return dateRanges
    }
    
    func dateGroupString(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        guard let days = components.day else {
            return "Unknown"
        }
        
        switch days {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case 2...7:
            return "Last week"
        case 8...14:
            return "Last 2 weeks"
        case 15...21:
            return "Last 3 weeks"
        case 22...(calendar.range(of: .day, in: .month, for: now)?.count ?? 31):
            return "Past month"
        case let day where day > 31:
            let months = calendar.dateComponents([.month], from: date, to: now).month ?? 0
            if months < 12 {
                return "Past \(months) months"
            } else {
                let years = calendar.dateComponents([.year], from: date, to: now).year ?? 0
                if years == 1 {
                    return "Past year"
                } else {
                    return "Past \(years) years"
                }
            }
        default:
            return "Unknown"
        }
    }
    
    func isNegativeTestOn(date: Date) -> Bool? {
        var matchingTests: [TestModel] = []
        let calendar = Calendar.current
        groupedTests.forEach { _date, _tests in
            if calendar.isDate(date.startOfDay, inSameDayAs: _date.startOfDay) {
                _tests.forEach { test in
                    matchingTests.append(test)
                }
            }
        }
        if matchingTests.isEmpty {
            return nil
        }
        return matchingTests.allSatisfy { $0.result == "negative" }
    }
    
    func learnMoreBtnClicked() {
        
    }
    
    func fetchContactsTests(id: UUID) async {
        DispatchQueue.main.async {
            self.isLoadingContactTests = true
        }
        Task {
            do {
                let fetchedTests = try await testService.fetchByUserId(columnName: "user_id", userId: id)
                DispatchQueue.main.async {
                    self.contactTests = fetchedTests
                    self.isLoadingContactTests = false
                    self.hasLoadedContactTests = true
                    self.groupTests(for: .contact)
                }
            } catch {
                print("An error occurred while fetching contact tests: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingContactTests = false
                }
            }
        }
    }
    
    func removeContactData() {
        contactTests.removeAll()
        contactLastTests.removeAll()
        hasLoadedContactTests = false
    }
    
}
