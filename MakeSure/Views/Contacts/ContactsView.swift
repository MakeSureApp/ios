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
    @State private var selectedContact: Contact?
    
    var body: some View {
        ZStack {
            VStack {
                CalendarView(viewModel: viewModel)
                
                HStack {
                    Text("My contacts")
                        .font(.poppinsBoldFont(size: 23))
                        .padding()
                    Button {
                        
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
                    .font(.poppinsBoldFont(size: 14))
                    .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView {
                    ForEach(viewModel.contacts) { contact in
                        ContactView(contact: contact, showMenu: $showMenu, selectedContact: $selectedContact)
                    }
                }
            }
            .padding(.top, -50)
            
            if showMenu, let contact = selectedContact {
                ContactMenu(contact: contact, showMenu: $showMenu)
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
                                .frame(width: 23, height: 23)
                                .clipShape(Circle())
                                .offset(x: CGFloat(index) * -4, y: 0)
                          
                                Text(date)
                                    .font(.poppinsBoldFont(size: 12))
                                    .padding(.horizontal, 8)
                                    .foregroundColor(.white)
                            
                        }
                        .padding(.top, -4)
                    }
                }
            }
        }
        .frame(height: 50)
        .padding(6)
    }
}

struct CalendarView: View {
    @ObservedObject var viewModel: ContactsViewModel
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let lastSevenDates: [Date]
    let calendar = Calendar.current

    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        for daysAgo in 0...6 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        self.lastSevenDates = dates.reversed()
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(lastSevenDates, id: \.self) { date in
                    let dayOfWeek = days[calendar.component(.weekday, from: date) - 1]
                    let dateString = String(calendar.component(.day, from: date))
                    let metContacts = viewModel.contactsMetOn(date: date)
                    DayView(day: dayOfWeek, date: dateString, metContacts: metContacts)
                }
            }
            .padding()
        }
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
