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
    @State private var showContact = false
    @State private var selectedContact: Contact?
    @State private var menuYOffset: CGFloat = 0
    @State private var showSharingTestView = false
    
    var body: some View {
        ZStack {
            VStack {
                CalendarScrollView(viewModel: viewModel)
                
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
                        Text("Date followed")
                            .foregroundColor(.black)
                            .font(.poppinsBoldFont(size: 14))
                            .tag(ContactsViewModel.SortBy.dateFollowed)
                        Text("Recent meetings")
                            .foregroundColor(.black)
                            .font(.poppinsBoldFont(size: 10))
                            .tag(ContactsViewModel.SortBy.dateRecentMeetings)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.black)
                    .font(.poppinsBoldFont(size: 10))
                    .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, -14)
                
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.contacts) { contact in
                            GeometryReader { geometry in
                                ContactItemView(viewModel: viewModel, contact: contact, showMenu: $showMenu, showContact: $showContact, selectedContact: $selectedContact)
                                    .onTapGesture {
                                        if showMenu {
                                            showMenu = false
                                        } else {
                                            withAnimation {
                                                showContact = true
                                                selectedContact = contact
                                                menuYOffset = geometry.frame(in: .global).minY + geometry.size.height
                                                print("click \(menuYOffset)")
                                            }
                                        }
                                    }
                                    .onLongPressGesture {
                                        withAnimation {
                                            showMenu = true
                                            selectedContact = contact
                                            menuYOffset = geometry.frame(in: .global).minY + geometry.size.height
                                            print("press \(menuYOffset)")
                                        }
                                    }
                            }
                            .frame(height: 70)
                        }
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
                showMenu = false
                showContact = false
                viewModel.showCalendar = false
                viewModel.showContactCalendar = false
            }) {
                Rectangle()
                    .fill(Color.clear)
                    .ignoresSafeArea()
                    .allowsHitTesting(!showContact)
            }
            .zIndex(-1)
            if showMenu, let contact = selectedContact {
                ContactMenu(viewModel: viewModel, contact: contact, showMenu: $showMenu, showSharingTest: $showSharingTestView)
                   // .offset(y: menuYOffset)
            }
            if showSharingTestView, let date = viewModel.getMyLatestTestDate(),  let contact = selectedContact {
                VStack {
                    Spacer()
                    ShareLastTestView(viewModel: viewModel, isShowView: $showSharingTestView, contact: contact, date: date)
                }
            }
            if viewModel.showContactCalendar, let contact = selectedContact {
                VStack {
                    Spacer()
                    GraphicalDatePicker(viewModel: viewModel, currentMonth: Date(), isFromContactView: true, contactId: contact.id)
                        .padding(.bottom, 30)
                }
            }
        }
    }
}

extension VerticalAlignment {
    struct MenuAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[VerticalAlignment.center]
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
            Image(uiImage: contact.image)
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
               // if !viewModel.showCalendar {
                    showMenu.toggle()
                withAnimation {
                    selectedContact = contact
                }
                //}
            }) {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(showMenu && selectedContact != nil && selectedContact!.id == contact.id ? Color.gradientPurple3.opacity(0.3) : .white )
        .cornerRadius(12)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture {
           // if !viewModel.showCalendar {
                showMenu = false
                selectedContact = contact
                showContact.toggle()
            //}
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
                            Image(uiImage: contact.image)
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
                                    viewModel.dateToStartInCalendar = date
                                    viewModel.showCalendar.toggle()
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

struct ContactMenu: View {
    @ObservedObject var viewModel: ContactsViewModel
    let contact: Contact
    @Binding var showMenu: Bool
    @Binding var showSharingTest: Bool

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button(action: shareMyTest) {
                    Text("Share my test")
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
                Button(action: addDate) {
                    Text("Add date")
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
                Button(action: rename) {
                    Text("Rename")
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
            }
            VStack {
                Button(action: delete) {
                    Text("Delete")
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
                Button(action: block) {
                    Text("Block")
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
                Button(action: report) {
                    Text("Report")
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
            }
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
        showSharingTest = true
        showMenu = false
    }

    private func addDate() {
        viewModel.showContactCalendar = true
        showMenu = false
    }

    private func rename() {
        // Implement rename functionality
    }

    private func delete() {
        viewModel.deleteContact(id: contact.id)
        showMenu = false
    }

    private func block() {
        viewModel.addUserToBlacklist(id: contact.id)
        showMenu = false
    }

    private func report() {
        // Implement report functionality
        showMenu = false
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView(viewModel: ContactsViewModel())
    }
}
