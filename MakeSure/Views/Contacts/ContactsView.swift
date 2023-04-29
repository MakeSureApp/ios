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
    @State private var showContact = false
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
                        ContactItemView(viewModel: viewModel, contact: contact, showMenu: $showMenu, showContact: $showContact, selectedContact: $selectedContact)
                    }
                }
            }
            .padding(.top, -50)
            .sheet(isPresented: $showContact) {
                if let contact = selectedContact {
                    ContactView(contact: contact, viewModel: viewModel)
                }
            }
            Button(action: {
                showContact = false
                showCalendar = false
                viewModel.showCalendar = false
            }) {
                Rectangle()
                    .fill(Color.clear)
                    .ignoresSafeArea()
                    .allowsHitTesting(!showContact && !showCalendar)
            }
            .zIndex(-1)

            
            if showCalendar, !viewModel.showCalendar {
                VStack {
                    GraphicalDatePicker(viewModel: viewModel, currentMonth: selectedDate, isFromContactView: false)
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

struct ContactItemView: View {
    @ObservedObject var viewModel: ContactsViewModel
    let contact: Contact
    @Binding var showMenu: Bool
    @Binding var showContact: Bool
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
                
                let date = viewModel.getLastDateWith(contact: contact)
                
                if let metDateString = viewModel.getMetDateString(date), let date {
                    Text(metDateString)
                        .font(.poppinsRegularFont(size: 9))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.metDateColor(date: date))
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
        .cornerRadius(10)
        .onTapGesture {
            selectedContact = contact
            showContact.toggle()
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
