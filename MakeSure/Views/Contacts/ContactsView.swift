//
//  ContactsIView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct ContactsView: View {
    @StateObject var viewModel: ContactsViewModel
    @State private var showMenu = false
    @State private var showCalendar = false
    @State private var selectedDate = Date()
    @State private var selectedContact: Contact?
    
    var body: some View {
        ZStack {
            VStack {
                CalendarScrollView(viewModel: viewModel, showCalendar: $showCalendar, selectedDate: $selectedDate)
                
                HStack {
                    Text("My contacts")
                        .font(.poppinsBoldFont(size: 23))
                        .padding()
                    Button {
                        viewModel.copyLinkBtnClicked()
                    } label: {
                        Image("copyProfileLinkIcon")
                            .resizable()
                            .frame(width: 21, height: 21)
                    }
                    Spacer()
                }
                
                HStack {
                    Text("Sort by")
                        .font(.poppinsRegularFont(size: 14))
                    Picker("Sort by", selection: $viewModel.sortBy) {
                        Text("Date followed").tag(ContactsViewModel.SortBy.dateFollowed)
                        Text("Recent meetings").tag(ContactsViewModel.SortBy.dateRecentMeetings)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.poppinsBoldFont(size: 10))
                    .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, -14)
                
                ScrollView {
                    ForEach(viewModel.contacts) { contact in
                        ContactView(contact: contact, showMenu: $showMenu, selectedContact: $selectedContact)
                    }
                }
            }
            .padding(.top, -50)
            .onTapGesture {
                showCalendar = false
                viewModel.showCalendar = false
            }
            
            if showCalendar, !viewModel.showCalendar {
                VStack {
                    GraphicalDatePicker(startDate: viewModel.startDateInCalendar, metContacts: viewModel.contacts, testsDates: viewModel.getTestsDates(), currentMonth: $selectedDate)
                        .edgesIgnoringSafeArea(.all)
                        .padding(.top, 50)
                    Spacer()
                }
            }
            
            if showMenu, let contact = selectedContact {
                ContactMenu(contact: contact, showMenu: $showMenu)
                    .onTapGesture {
                        showMenu.toggle()
                    }
                    //.background(BlurView(style: .systemThinMaterial))
            }
        }
    }
}

struct ContactView: View {
    let contact: Contact
    @Binding var showMenu: Bool
    @Binding var selectedContact: Contact?

    var body: some View {
        HStack {
            contact.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 63, height: 63)
                .clipShape(Circle())
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.poppinsBoldFont(size: 14))
                
                if let metDateString = metDateString, let date = contact.metDate {
                    Text(metDateString)
                        .font(.poppinsRegularFont(size: 9))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(metDateColor(date: date))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Button(action: {
                showMenu.toggle()
                selectedContact = contact
            }) {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var metDateString: String? {
        guard let metDate = contact.metDate else { return nil }
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
    
    private func metDateColor(date: Date) -> Color {
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
}

struct DayView: View {
    let day: String
    let date: String
    let metContacts: [Contact]

    var body: some View {
        VStack {
            Text(day)
                .font(.poppinsRegularFont(size: 12))
                .padding(2)
            if metContacts.isEmpty {
                Text(date)
                    .font(.poppinsRegularFont(size: 12))
                    .padding(.horizontal, 8)
            } else {
                ZStack {
                    ForEach(metContacts.indices, id: \.self) { index in
                        let contact = metContacts[index]
                        ZStack(alignment: .center) {
                            contact.image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .offset(x: CGFloat(index) * -4, y: 0)
                                .overlay {
                                    Circle()
                                        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                                }
                          
                                Text(date)
                                    .font(.poppinsBoldFont(size: 12))
                                    .padding(.horizontal, 8)
                                    .foregroundColor(.white)
                            
                        }
                        .padding(.top, -5)
                    }
                }
            }
        }
        .frame(height: 50)
        .padding(6)
    }
}

struct CalendarScrollView: View {
    @ObservedObject var viewModel: ContactsViewModel
    @Binding var showCalendar: Bool
    @Binding var selectedDate: Date
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let calendar = Calendar.current

    @State private var currentDate = Date()

    func dateFor(weeksAgo: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: currentDate) ?? currentDate
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollViewProxy in
                LazyHStack(spacing: 10) {
                    ForEach((0..<52).reversed(), id: \.self) { weeksAgo in
                        ForEach((0..<7).reversed(), id: \.self) { dayOffset in
                            let date = calendar.date(byAdding: .day, value: -dayOffset, to: dateFor(weeksAgo: weeksAgo))!
                            let dayOfWeek = days[calendar.component(.weekday, from: date) - 1]
                            let dateString = String(calendar.component(.day, from: date))
                            let metContacts = viewModel.contactsMetOn(date: date)
                            DayView(day: dayOfWeek, date: dateString, metContacts: metContacts)
                                .id("\(weeksAgo)-\(dayOffset)")
                                .onTapGesture {
                                    selectedDate = date
                                    showCalendar.toggle()
                                }
                        }
                    }
                }
                .frame(height: 50)
                .padding()
                .onAppear {
                    let weeksAgo = 0
                    let dayOffset = 0
                    let scrollId = "\(weeksAgo)-\(dayOffset)"
                    scrollViewProxy.scrollTo(scrollId, anchor: .trailing)
                }
            }
        }
    }
}

struct GraphicalDatePicker: View {
    let startDate: Date
    let metContacts: [Contact]
    let testsDates: [Date]
    @Binding var currentMonth: Date
    
    var body: some View {
        CustomCalendarView(startDate: startDate, metContacts: metContacts, testsDates: testsDates, currentMonth: $currentMonth)
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .shadow(color: .gray, radius: 10, x: 0, y: 0)
    }
}

struct CustomCalendarView: View {
    let startDate: Date
    let endDate = Date()
    let calendar = Calendar.current
    let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    let metContacts: [Contact]
    let testsDates: [Date]
    @Binding var currentMonth: Date

    private func contactsMetOn(date: Date) -> [Contact] {
        metContacts.filter { contact in
            if let contactDate = contact.metDate {
                return calendar.isDate(date, inSameDayAs: contactDate)
            }
            return false
        }
    }
    
    private func testsOn(date: Date) -> [Date] {
        testsDates.filter { testDate in
            return testDate == date
        }
    }

    private func dayView(for date: Date) -> some View {
        Group {
            if date != Date.distantPast {
                ZStack {
                    if let dates = testsOn(date: date), !dates.isEmpty {
                        ForEach(testsDates.indices, id: \.self) { index in
                            Circle()
                                .frame(width: 33, height: 33)
                                .foregroundColor(Color(red: 95/255, green: 233/255, blue: 134/255))
                        }
                        .zIndex(0)
                    }
                    
                    if let contacts = contactsMetOn(date: date), !contacts.isEmpty {
                        ForEach(contacts.indices, id: \.self) { index in
                            let contact = contacts[index]
                            contact.image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 33, height: 33)
                                .clipShape(Circle())
                                .offset(x: CGFloat(index) * -4, y: 0)
                                .overlay {
                                    Circle()
                                        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                                }
                        }
                    }
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(.poppinsRegularFont(size: 20))
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("")
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 40, height: 30)
    }

    private func navigateMonth(by value: Int) {
        let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth)!
        if newMonth >= startDate && newMonth <= endDate {
            currentMonth = newMonth
        }
    }
    
    private func weeks(in month: Date) -> [[Date]] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        let numberOfDays = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day! + 1
        let numberOfWeeks = Int(ceil(Double(numberOfDays + calendar.component(.weekday, from: startOfMonth) - 1) / 7))
        
        var dates: [[Date]] = Array(repeating: Array(repeating: startOfMonth, count: 7), count: numberOfWeeks)
        
        var currentDate = startOfMonth
        for i in 0..<numberOfWeeks {
            for j in 0..<7 {
                if (i == 0 && j < calendar.component(.weekday, from: startOfMonth) - 1) || currentDate > endOfMonth {
                    dates[i][j] = Date.distantPast
                } else {
                    dates[i][j] = currentDate
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                }
            }
        }
        
        return dates
    }
    
    private func monthRange(for date: Date) -> ClosedRange<Date> {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        return startOfMonth...endOfMonth
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(calendar.monthSymbols[calendar.component(.month, from: currentMonth) - 1]) \(calendar.component(.year, from: currentMonth))")
                    .font(.poppinsBoldFont(size: 17))
                
                Spacer()
                
                Button(action: { navigateMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(currentMonth == startDate ? .white : .black)
                }
                .disabled(currentMonth == startDate)
                .padding(.trailing, 8)

                Button(action: { navigateMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(currentMonth == endDate ? .white : .black)
                }
                .disabled(currentMonth == endDate)
            }
            .padding(.bottom)

            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.poppinsRegularFont(size: 13))
                        .foregroundColor(.gray)
                }
            }

            ForEach(weeks(in: currentMonth), id: \.self) { week in
                HStack {
                    ForEach(week, id: \.self) { date in
                        dayView(for: date)
                    }
                }
            }
        }
        .padding()
    }
}


struct MenuOverlay: View {
    @Binding var showMenu: Bool
    let contact: Contact
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if geometry.safeAreaInsets.top + geometry.frame(in: .global).minY < geometry.size.height / 2 {
                    Spacer()
                    ContactMenu(contact: contact, showMenu: $showMenu)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color(.systemGray6), radius: 10, x: 0, y: 0)
                } else {
                    ContactMenu(contact: contact, showMenu: $showMenu)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color(.systemGray6), radius: 10, x: 0, y: 0)
                    Spacer()
                }
            }
            .opacity(showMenu ? 1 : 0)
            .animation(.easeInOut)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                showMenu.toggle()
            }
        }
    }
}

struct ContactMenu: View {
    let contact: Contact
    @Binding var showMenu: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: shareMyTest) { Text("Share my test") }
            Button(action: addDate) { Text("Add date") }
            Button(action: rename) { Text("Rename") }
            Button(action: delete) { Text("Delete") }
            Button(action: block) { Text("Block") }
            Button(action: report) { Text("Report") }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .onTapGesture {
            showMenu = false
        }
    }

    private func shareMyTest() {
        // Implement shareMyTest functionality
    }

    private func addDate() {
        // Implement addDate functionality
    }

    private func rename() {
        // Implement rename functionality
    }

    private func delete() {
        // Implement delete functionality
    }

    private func block() {
        // Implement block functionality
    }

    private func report() {
        // Implement report functionality
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView(viewModel: ContactsViewModel())
    }
}
