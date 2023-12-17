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
    @State private var isAnimating: Bool = false
    @State private var isAnimatingMeetings: Bool = false
    @State private var topPadding: CGFloat = 0.0
    @State private var isShowingSharingTestView = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    ContactsCalendarScrollView(showMenu: $showMenu)
                        .environmentObject(viewModel)
                        .environmentObject(testsViewModel)
                    
                    HStack {
                        Text("my_contacts_section".localized)
                            .font(.montserratBoldFont(size: 23))
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
                            .font(.montserratRegularFont(size: 14))
                        Picker("sort_by_label".localized, selection: $viewModel.sortBy) {
                            Text("alphabetically".localized)
                                .foregroundColor(.black)
                                .font(.montserratBoldFont(size: 14))
                                .tag(ContactsViewModel.SortBy.alphabetically)
                            Text("recent_dates_option".localized)
                                .foregroundColor(.black)
                                .font(.montserratBoldFont(size: 10))
                                .tag(ContactsViewModel.SortBy.dateRecentMeetings)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.black)
                        .font(.montserratBoldFont(size: 10))
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
                                        ContactItemWithMenuView(
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
                                                withAnimation {
                                                    showMenu.toggle()
                                                }
                                            } else if viewModel.showCalendar {
                                                withAnimation {
                                                    viewModel.showCalendar.toggle()
                                                }
                                            } else {
                                                withAnimation {
                                                    selectedContact = contact
                                                    showContact = true
                                                    menuYOffset = geometry.frame(in: .global).minY + geometry.size.height
                                                }
                                            }
                                        }
                                        .onLongPressGesture {
                                            if !showMenu && !viewModel.showCalendar {
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
                            withAnimation {
                                viewModel.showCalendar = false
                                viewModel.showContactCalendar = false
                                showMenu = false
                                selectedContact = nil
                            }
                        }
                    } else {
                        Text("no_contacts".localized)
                            .font(.montserratRegularFont(size: 16))
                            .foregroundColor(.gray)
                            .padding()
                            .padding(.top)
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
                    withAnimation {
                        showMenu = false
                        showContact = false
                        selectedContact = nil
                        viewModel.showCalendar = false
                        viewModel.showContactCalendar = false
                    }
                }) {
                    Rectangle()
                        .fill(Color.clear)
                        .ignoresSafeArea()
                        .allowsHitTesting(!showContact)
                }
                .zIndex(-1)
//                .overlay(
//                    (isShowingBlockContactMenu || isShowingDeletingContactMenu || isShowingReportContactMenu) ? Color.black.opacity(0.5)
//                        .edgesIgnoringSafeArea(.all)
//                        .cornerRadius(20)
//                        .onTapGesture {
//                            withAnimation {
//                                showMenu = false
//                                isShowingBlockContactMenu = false
//                                isShowingDeletingContactMenu = false
//                                isShowingReportContactMenu = false
//                            }
//                        } : nil)
                if showMenu, let contact = selectedContact {
                    let isEnabled = !viewModel.checkIfContactBlockedMe(user: contact)
                    ContactMenu(
                        contact: contact,
                        isEnabled: isEnabled,
                        showMenu: $showMenu,
                        showSharingTest: $isShowingSharingTestView,
                        showContactCalendar: $viewModel.showContactCalendar,
                        onBlock: {
                            withAnimation {
                                showMenu = false
                            }
                            Task {
                                await viewModel.addUserToBlacklist(id: contact.id)
                            }
                        }, onDelete: {
                            withAnimation {
                                showMenu = false
                            }
                            Task {
                                await viewModel.deleteContact(id: contact.id)
                            }
                        }, onReport: { text, userId in
                            withAnimation {
                                showMenu = false
                            }
                            Task {
                                await viewModel.sendComplaintReport(text: text, reportedUserId: userId)
                            }
                        }
                    )
                    .environmentObject(viewModel)
                    .offset(y: menuYOffset)
                }
                if isShowingSharingTestView, let date = testsViewModel.lastTests.first?.date, let contact = selectedContact {
                    VStack {
                        Spacer()
                        ShareLastTestView(isShowView: $isShowingSharingTestView, contact: contact, date: date)
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
                if viewModel.isSendingComplaint {
                    RotatingShapesLoader(animate: $isAnimating, color: .black)
                        .frame(maxWidth: 100)
                        .padding(.top, 50)
                        .onAppear {
                            isAnimating = true
                        }
                        .onDisappear {
                            isAnimating = false
                        }
                }
                if viewModel.hasSentComplaint {
                    VStack {
                        Spacer()
                        Text("complaint_has_been_sent".localized)
                            .font(.montserratRegularFont(size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(.green.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(color: .gray, radius: 10)
                    }
                    .padding()
                    .padding(.bottom, 26)
                }
//                if isShowingBlockContactMenu, let contact = selectedContact {
//                    AlertMenu(alertText: getBlockAlertText(contact.name), actionBtnText: "block_button".localized.uppercased(),
//                              onCancel: {
//                        withAnimation {
//                            isShowingBlockContactMenu.toggle()
//                        }
//                    }, onAction: {
//                        Task {
//                            await viewModel.addUserToBlacklist(id: contact.id)
//                        }
//                        withAnimation {
//                            isShowingBlockContactMenu.toggle()
//                        }
//                    })
//                }
//                if isShowingDeletingContactMenu, let contact = selectedContact {
//                    AlertMenu(alertText: getDeleteAlertText(contact.name), actionBtnText: "delete_button".localized.uppercased(),
//                              onCancel: {
//                        withAnimation {
//                            isShowingDeletingContactMenu.toggle()
//                        }
//                    }, onAction: {
//                        Task {
//                            await viewModel.deleteContact(id: contact.id)
//                        }
//                        withAnimation {
//                            isShowingDeletingContactMenu.toggle()
//                        }
//                    })
//                }
//                if isShowingReportContactMenu {
//                    AlertTextFieldMenu(alertText: "reason_for_complaint".localized, actionBtnText: "report_button".localized, placeholderText: "explain_situation".localized, onCancel: {
//                        withAnimation {
//                            isShowingReportContactMenu = false
//                        }
//                    }) { text in
//                        Task {
//                            await viewModel.sendComplaintReport(text: text)
//                        }
//                        withAnimation {
//                            isShowingReportContactMenu = false
//                        }
//                    }
//                }
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

struct ContactItemWithMenuView: View {
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
                    .font(.montserratBoldFont(size: 14))
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
                    
                    if let metDateString = date.getMetDateString, let date {
                        Text(metDateString)
                            .font(.montserratRegularFont(size: 9))
                            .foregroundColor(date.getMetDateTextColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(date.getMetDateBackgroundColor)
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
                if !viewModel.showCalendar {
                    withAnimation {
                        if !showMenu {
                            selectedContact = contact
                        }
                        showMenu.toggle()
                    }
                }
            }) {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(showMenu && selectedContact != nil && selectedContact!.id == contact.id ? Color.gradientPurple3.opacity(0.3) : .white )
        .cornerRadius(12)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            if showMenu {
                withAnimation {
                    showMenu = false
                }
            } else if viewModel.showCalendar {
                withAnimation {
                    viewModel.showCalendar = false
                }
            } else if isEnabled {
                withAnimation {
                    selectedContact = contact
                    showMenu = false
                    showContact.toggle()
                }
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
                .font(.montserratRegularFont(size: 12))
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
                                    .font(.montserratBoldFont(size: 15))
                                    .foregroundColor(.black)
                                    .overlay {
                                        Text(dateString)
                                            .font(.montserratBoldFont(size: 12))
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
                        .font(.montserratRegularFont(size: 12))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.horizontal, 8)
                }
            } else {
                Text(dateString)
                    .font(.montserratRegularFont(size: 12))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
            }
            
        }
        .frame(height: 50)
        .padding(6)
    }
}

struct ContactsCalendarScrollView: View {
    @Binding var showMenu: Bool
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
                                    if !showMenu {
                                        viewModel.dateToStartInCalendar = date
                                        withAnimation {
                                            viewModel.showCalendar.toggle()
                                        }
                                    }
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
    let contact: UserModel
    let isEnabled: Bool
    @Binding var showMenu: Bool
    @Binding var showSharingTest: Bool
    @Binding var showContactCalendar: Bool
    let onBlock: () -> Void
    let onDelete: () -> Void
    let onReport: (String, UUID) -> Void
    
    @State private var showBlockMenu: Bool = false
    @State private var showDeleteMenu: Bool = false
    @State private var showReportMenu: Bool = false
    
    @State private var reportText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            if isEnabled {
                VStack {
                    Button(action: shareMyTest) {
                        Text("share_my_test_button".localized)
                            .font(.montserratRegularFont(size: 16))
                            .foregroundColor(CustomColors.darkBlue)
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                    }
                    Divider()
                        .frame(width: 140)
                    Button(action: addDate) {
                        Text("add_date_button".localized)
                            .font(.montserratRegularFont(size: 16))
                            .foregroundColor(CustomColors.darkBlue)
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                    }
                    Divider()
                        .frame(width: 140)
//                    Button(action: rename) {
//                        Text("rename_button".localized)
//                            .font(.montserratRegularFont(size: 16))
//                            .foregroundColor(.black)
//                            .padding(.horizontal)
//                            .padding(.vertical, 3)
//                    }
//                    Divider()
//                        .frame(width: 140)
                }
            }
            VStack {
                Button(action: delete) {
                    Text("delete_button".localized)
                        .font(.montserratRegularFont(size: 16))
                        .foregroundColor(Color(red: 1, green: 50.0/255.0, blue: 38.0/255.0))
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                .alert(isPresented: $showDeleteMenu) {
                    Alert(
                        title: Text(getDeleteAlertText()),
                        message: Text("user_will_disappear_from_contacts".localized),
                        primaryButton: .destructive(Text("OK")) {
                            onDelete()
                        },
                        secondaryButton: .cancel()
                    )
                }
                Divider()
                    .frame(width: 140)
                Button(action: block) {
                    Text("block_button".localized)
                        .font(.montserratRegularFont(size: 16))
                        .foregroundColor(Color(red: 1, green: 50.0/255.0, blue: 38.0/255.0))
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                .alert(isPresented: $showBlockMenu) {
                    Alert(
                        title: Text(getBlockAlertText()),
                        message: Text("user_will_disappear_from_contacts".localized),
                        primaryButton: .destructive(Text("OK")) {
                            onBlock()
                        },
                        secondaryButton: .cancel()
                    )
                }
                Divider()
                    .frame(width: 140)
                Button(action: report) {
                    Text("report_button".localized)
                        .font(.montserratRegularFont(size: 16))
                        .foregroundColor(Color(red: 1, green: 50.0/255.0, blue: 38.0/255.0))
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                }
                .alert("reason_for_complaint".localized, isPresented: $showReportMenu) {
                    Button("cancel_button".localized, role: .cancel, action: {})
                    Button("complain".localized, role: .destructive) {
                        if reportText.count > 7 {
                            onReport(reportText, contact.id)
                        }
                    }
                    TextField("explain_situation".localized, text: $reportText)
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
    
    private func getBlockAlertText() -> String {
        return String(format: "you_sure_to_block_contact".localized, contact.name)
    }
    
    private func getDeleteAlertText() -> String {
        return String(format: "you_sure_to_delete_contact".localized, contact.name)
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
            showContactCalendar = true
        }
    }

    private func rename() {
        // Implement rename functionality
    }

    private func delete() {
        withAnimation {
            showDeleteMenu.toggle()
        }
    }

    private func block() {
        withAnimation {
            showBlockMenu.toggle()
        }
    }

    private func report() {
        // Implement report functionality
        withAnimation {
            showReportMenu.toggle()
        }
    }
}

struct ReportAlertView: View {
    @State private var reportText: String = ""
    @Binding var isPresented: Bool
    let onReport: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("reason_for_complaint".localized)
                .font(.headline)
            
            TextEditor(text: $reportText)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding()
            
            Button("explain_situation".localized) {
                onReport(reportText)
                isPresented = false
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            
            Button("cancel_button".localized) {
                isPresented = false
            }
            .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
            .environmentObject(ContactsViewModel())
            .environmentObject(TestsViewModel(mainViewModel: MainViewModel()))
    }
}

