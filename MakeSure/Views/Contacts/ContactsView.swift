//
//  ContactsIView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct ContactsView: View {
    
    @EnvironmentObject var viewModel: ContactsViewModel
    @EnvironmentObject var testsViewModel: TestsViewModel
    
    @State private var showMenu = false
    @State private var showContact = false
    @State private var selectedContact: UserModel?
    @State private var menuYOffset: CGFloat = 0
    @State private var showSharingTestView = false
    @State private var isAnimating: Bool = false
    @State private var isAnimatingMeetings: Bool = false
    @State private var topPadding: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            VStack {
                ContactsCalendarScrollView()
                    .environmentObject(viewModel)
                    .environmentObject(testsViewModel)
                
                HStack {
                    Text("my_contacts_section".localized)
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
                    Text("sort_by_label".localized)
                        .font(.poppinsRegularFont(size: 14))
                    Picker("sort_by_label".localized, selection: $viewModel.sortBy) {
                        Text("date_followed_option".localized)
                            .foregroundColor(.black)
                            .font(.poppinsBoldFont(size: 14))
                            .tag(ContactsViewModel.SortBy.dateFollowed)
                        Text("recent_dates_option".localized)
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
                
                if viewModel.isLoadingContacts && viewModel.contacts.isEmpty {
                    RotatingShapesLoader(animate: $isAnimating, color: .black)
                        .frame(maxWidth: 100)
                        .padding(.top, 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                    Spacer()
                } else if viewModel.hasLoadedContacts || !viewModel.contacts.isEmpty {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.contacts) { contact in
                                GeometryReader { geometry in
                                    ContactItemView(
                                        viewModel: viewModel,
                                        contact: contact,
                                        isEnabled: !viewModel.checkIfContactBlockedMe(user: contact),
                                        showMenu: $showMenu,
                                        showContact: $showContact,
                                        selectedContact: $selectedContact,
                                        isAnimatingMeetings: $isAnimatingMeetings
                                    )
                                        .onTapGesture {
                                            if showMenu {
                                                showMenu.toggle()
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
                                            if !showMenu {
                                                withAnimation {
                                                    showMenu = true
                                                    selectedContact = contact
                                                }
                                            }
                                        }
                                }
                                .frame(height: 70)
                                .task {
                                    await viewModel.loadImage(user: contact, for: .contact)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        viewModel.showCalendar = false
                        viewModel.showContactCalendar = false
                        showMenu = false
                        selectedContact = nil
                    }
                } else {
                    Spacer()
                    Text("no_contacts".localized)
                        .font(.poppinsBoldFont(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Spacer()
                }
            }
            .sheet(isPresented: $showContact) {
                if let contact = selectedContact {
                    ContactView(contact: contact)
                        .environmentObject(viewModel)
                        .environmentObject(testsViewModel)
                }
            }
            Button(action: {
                showMenu = false
                showContact = false
                selectedContact = nil
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
                let isEnabled = !viewModel.checkIfContactBlockedMe(user: contact)
                ContactMenu(
                    contact: contact,
                    isEnabled: isEnabled,
                    showMenu: $showMenu,
                    showSharingTest: $showSharingTestView
                )
                .environmentObject(viewModel)
                .offset(y: menuYOffset)
            }
            if showSharingTestView, let date = testsViewModel.lastTests.first?.date, let contact = selectedContact {
                VStack {
                    Spacer()
                    ShareLastTestView(isShowView: $showSharingTestView, contact: contact, date: date)
                        .environmentObject(viewModel)
                }
            }
            if viewModel.showContactCalendar, let contact = selectedContact {
                VStack {
                    Spacer()
                    GraphicalDatePicker(viewModel: viewModel, testsViewModel: testsViewModel, currentMonth: Date(), isFromContactView: true, contactId: contact.id)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            if geometry.safeAreaInsets.top > 0 {
                topPadding = 80
            } else {
                topPadding = 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            if geometry.safeAreaInsets.top > 0 {
                topPadding = 80
            } else {
                topPadding = 0
            }
        }
        .padding(.top, topPadding)
        .ignoresSafeArea(.all)
       
        .task {
            await viewModel.fetchContacts()
            await viewModel.fetchMeetings()
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
    let contact: UserModel
    let isEnabled: Bool
    @Binding var showMenu: Bool
    @Binding var showContact: Bool
    @Binding var selectedContact: UserModel?
    @Binding var isAnimatingMeetings: Bool
    @State private var isAnimatingImage: Bool = true
    @State private var isAnimating: Bool = true

    var body: some View {
        HStack {
            if let image = viewModel.contactsImages[contact.id], isEnabled {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 63, height: 63)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
            } else if contact.photoUrl == nil || !isEnabled {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 63, height: 63)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
            } else {
                Circle()
                    .foregroundColor(.gradientDarkBlue)
                    .frame(width: 63, height: 63)
                    .overlay(
                        RotatingShapesLoader(animate: $isAnimatingImage)
                            .frame(maxWidth: 25)
                            .onAppear {
                                isAnimatingImage = true
                            }
                            .onDisappear {
                                isAnimatingImage = false
                            }
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.poppinsBoldFont(size: 14))
                    .foregroundColor(isEnabled ? .black : .gray)
                
                if viewModel.isLoadingMeetings && viewModel.contacts.isEmpty  {
                    HStack(alignment: .center) {
                        RowOfShapesLoader(animate: $isAnimatingMeetings, color: .gray.opacity(0.8), count: 3, spacing: 3)
                            .frame(maxWidth: 60, maxHeight: 18)
                            .onAppear {
                                isAnimatingMeetings = true
                            }
                            .onDisappear {
                                isAnimatingMeetings = false
                            }
                    }
                    .padding(.leading, 28)
                    .padding(.top, 6)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
                } else if viewModel.hasLoadedMeetings || !viewModel.contacts.isEmpty  {
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
            }
            if selectedContact?.id == contact.id, viewModel.isAddingUserToBlacklist || viewModel.isDeletingContact {
                HStack(alignment: .center) {
                    RowOfShapesLoader(animate: $isAnimating, color: .gray.opacity(0.8), count: 3, spacing: 3)
                        .frame(maxWidth: 80, maxHeight: 18)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                }
                .padding(.leading, 28)
                .padding(.top, 6)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: {
               // if !viewModel.showCalendar {
                withAnimation {
                    if !showMenu {
                        selectedContact = contact
                    }
                    showMenu.toggle()
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
            if isEnabled {
                selectedContact = contact
                showMenu = false
                showContact.toggle()
            }
        }
    }
}

struct DayView: View {
    let day: String
    let date: Date
    let dateString: String
    let metContacts: [UserModel]
    @EnvironmentObject var viewModel: ContactsViewModel
    @EnvironmentObject var testsViewModel: TestsViewModel

    var body: some View {
        VStack {
            Text(day)
                .font(.poppinsRegularFont(size: 12))
                .padding(2)
            if !metContacts.isEmpty {
                ZStack {
                    ForEach(metContacts.indices, id: \.self) { index in
                        let contact = metContacts[index]
                        let isEnabled = !viewModel.checkIfContactBlockedMe(user: contact)
                        if let image = viewModel.contactsImages[contact.id] {
                            ZStack(alignment: .center) {
                                if isEnabled {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                        .offset(x: CGFloat(index) * -4, y: 0)
                                        .overlay {
                                            Circle()
                                                .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                                        }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .scaledToFill()
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                        .offset(x: CGFloat(index) * -4, y: 0)
                                        .overlay {
                                            Circle()
                                                .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                                        }
                                }
                                
                                Text(dateString)
                                    .font(.poppinsBoldFont(size: 15))
                                    .foregroundColor(.black)
                                    .overlay {
                                        Text(dateString)
                                            .font(.poppinsBoldFont(size: 12))
                                            .foregroundColor(.white)
                                            .shadow(color: .black, radius: 2)
                                    }
                                
                            }
                            .padding(.top, -5)
                        }
                    }
                }
            } else if let isNegativeTest = testsViewModel.isNegativeTestOn(date: date) {
                ZStack(alignment: .center) {
                    Circle()
                        .frame(width: 25, height: 25)
                        .foregroundColor(isNegativeTest ? .lightGreen : .orange)
                        .zIndex(0)
                    Text(dateString)
                        .font(.poppinsRegularFont(size: 12))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.horizontal, 8)
                }
            } else {
                Text(dateString)
                    .font(.poppinsRegularFont(size: 12))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
            }
            
        }
        .frame(height: 50)
        .padding(6)
    }
}

struct ContactsCalendarScrollView: View {
    @EnvironmentObject var viewModel: ContactsViewModel
    @EnvironmentObject var testsViewModel: TestsViewModel
    let days = [
        "sunday_short".localized,
        "monday_short".localized,
        "tuesday_short".localized,
        "wednesday_short".localized,
        "thursday_short".localized,
        "friday_short".localized,
        "saturday_short".localized
    ]
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
                            DayView(day: dayOfWeek, date: date, dateString: dateString, metContacts: metContacts)
                                .environmentObject(viewModel)
                                .environmentObject(testsViewModel)
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
    @EnvironmentObject var viewModel: ContactsViewModel
    let contact: UserModel
    let isEnabled: Bool
    @Binding var showMenu: Bool
    @Binding var showSharingTest: Bool

    var body: some View {
        VStack(alignment: .leading) {
            if isEnabled {
                VStack {
                    Button(action: shareMyTest) {
                        Text("share_my_test_button".localized)
                            .font(.poppinsRegularFont(size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                    }
                    Divider()
                        .frame(width: 140)
                    Button(action: addDate) {
                        Text("add_date_button".localized)
                            .font(.poppinsRegularFont(size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                    }
                    Divider()
                        .frame(width: 140)
                    Button(action: rename) {
                        Text("rename_button".localized)
                            .font(.poppinsRegularFont(size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                    }
                    Divider()
                        .frame(width: 140)
                }
            }
            VStack {
                Button(action: delete) {
                    Text("delete_button".localized)
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
                Button(action: block) {
                    Text("block_button".localized)
                        .font(.poppinsRegularFont(size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                Divider()
                    .frame(width: 140)
                Button(action: report) {
                    Text("report_button".localized)
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
        withAnimation {
            showMenu = false
            showSharingTest = true
        }
    }

    private func addDate() {
        withAnimation {
            showMenu = false
            viewModel.showContactCalendar = true
        }
    }

    private func rename() {
        // Implement rename functionality
    }

    private func delete() {
        withAnimation {
            showMenu = false
        }
        Task {
            await viewModel.deleteContact(id: contact.id)
        }
    }

    private func block() {
        withAnimation {
            showMenu = false
        }
        Task {
            await viewModel.addUserToBlacklist(id: contact.id)
        }
    }

    private func report() {
        // Implement report functionality
        withAnimation {
            showMenu = false
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
            .environmentObject(ContactsViewModel())
            .environmentObject(TestsViewModel())
    }
}
