//
//  CalendarView.swift
//  MakeSure
//
//  Created by andreydem on 4/29/23.
//

import SwiftUI

struct GraphicalDatePicker: View {
    @ObservedObject var viewModel: ContactsViewModel
    @ObservedObject var testsViewModel: TestsViewModel
    let currentMonth: Date
    let isFromContactView: Bool
    let contactId: UUID?
    
    init(viewModel: ContactsViewModel, testsViewModel: TestsViewModel, currentMonth: Date, isFromContactView: Bool, contactId: UUID? = nil) {
        self.viewModel = viewModel
        self.testsViewModel = testsViewModel
        self.currentMonth = currentMonth
        self.isFromContactView = isFromContactView
        self.contactId = contactId
    }
    
    var body: some View {
        CustomCalendarView(viewModel: viewModel, testsViewModel: testsViewModel, currentMonth: currentMonth, isFromContactView: isFromContactView, contactId: contactId)
            .background(.white)
            .cornerRadius(18)
            .padding(.horizontal)
            .shadow(color: .gray, radius: 10, x: 0, y: 0)
    }
}

struct CustomCalendarView: View {
    @ObservedObject var viewModel: ContactsViewModel
    @ObservedObject var testsViewModel: TestsViewModel
    @State var currentMonth: Date
    let isFromContactView: Bool
    let startDate: Date
    let endDate = Date()
    @State private var isDateSelected = false
    @State private var isAddBtnClicked = false
    @State var selectedDate: Date?
    let contactId: UUID?
    var calendar = Calendar.current
    let days = [
        "sunday_short".localized.uppercased(),
        "monday_short".localized.uppercased(),
        "tuesday_short".localized.uppercased(),
        "wednesday_short".localized.uppercased(),
        "thursday_short".localized.uppercased(),
        "friday_short".localized.uppercased(),
        "saturday_short".localized.uppercased()
    ]
    
    init(viewModel: ContactsViewModel, testsViewModel: TestsViewModel, currentMonth: Date, isFromContactView: Bool, contactId: UUID?) {
        self.viewModel = viewModel
        self.testsViewModel = testsViewModel
        _currentMonth = State(initialValue: currentMonth)
        self.isFromContactView = isFromContactView
        self.contactId = contactId
        startDate = viewModel.startDateInCalendar
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
    }
    
    private func isSelectedDateInThePast() -> Bool {
        if let selectedDate, selectedDate < Date().addingTimeInterval(100) {
            return true
        }
        return false
    }

    private func dayView(for date: Date) -> some View {
        Button {
            if monthRange(for: currentMonth).contains(date) {
                selectedDate = date
            }
        } label: {
            HStack {
                if monthRange(for: currentMonth).contains(date) {
                    ZStack {
                        if let isNegativeTest = testsViewModel.isNegativeTestOn(date: date) {
                            Circle()
                                .frame(width: 33, height: 33)
                                .foregroundColor(isNegativeTest ? .lightGreen : .orange)
                                .zIndex(0)
                        }
                        let contactsMetOnTheDay = viewModel.contactsMetOn(date: date, withLimit: 2)
                        if selectedDate != date {
                            if !contactsMetOnTheDay.isEmpty {
                                ForEach(Array(contactsMetOnTheDay.enumerated()), id: \.element.id) { (index, contact) in
                                    let isEnabled = !viewModel.checkIfContactBlockedMe(user: contact)
                                    if let image = viewModel.contactsImages[contact.id] {
                                        if isEnabled {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 33, height: 33)
                                                .clipShape(Circle())
                                                .offset(getOffsetForImage(contactsMetOnTheDay.count, index))
                                                .overlay {
                                                    Circle()
                                                        .offset(getOffsetForImage(contactsMetOnTheDay.count, index))
                                                        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                                                }
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                                .scaledToFill()
                                                .frame(width: 33, height: 33)
                                                .clipShape(Circle())
                                                .offset(getOffsetForImage(contactsMetOnTheDay.count, index))
                                                .overlay {
                                                    Circle()
                                                        .offset(getOffsetForImage(contactsMetOnTheDay.count, index))
                                                        .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        let dateStr = calendar.component(.day, from: date)
                        let isSelectedDate = selectedDate == date
                        if isSelectedDate {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gradientPurple.opacity(0.9))
                        }
                        if !contactsMetOnTheDay.isEmpty {
                            Text("\(dateStr)")
                                .font(.montserratRegularFont(size: 20))
                                .foregroundColor(isSelectedDate ? .white : .black)
                                .overlay {
                                    Text("\(dateStr)")
                                        .font(.montserratRegularFont(size: 19))
                                        .foregroundColor(isSelectedDate ? .black : .white)
                                        .shadow(color: isSelectedDate ? .white : .black, radius: 2)
                                }
                        } else {
                            Text("\(dateStr)")
                                .font(.montserratRegularFont(size: 20))
                                .foregroundColor(isSelectedDate ? .white : .black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Text("")
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 40, height: 30)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getOffsetForImage(_ count: Int, _ index: Int) -> CGSize {
        if count == 2 {
            if index == 0 {
                return CGSize(width: -5, height: -5)
            } else {
                return CGSize(width: 5, height: 5)
            }
        } else {
            return CGSize(width: 0, height: 0)
        }
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

        var dates: [[Date]] = Array(repeating: [], count: numberOfWeeks)

        var currentDate = startOfMonth
        for i in 0..<numberOfWeeks {
            for j in 0..<7 {
                if (i == 0 && j < calendar.component(.weekday, from: startOfMonth) - 1) || currentDate > endOfMonth {
                    dates[i].append(Date.distantPast)
                } else {
                    dates[i].append(currentDate)
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
                    .font(.montserratBoldFont(size: 17))
                
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
                        .font(.montserratRegularFont(size: 13))
                        .foregroundColor(.gray)
                }
            }
            
            ForEach(weeks(in: currentMonth).indices, id: \.self) { weekIndex in
                HStack {
                    ForEach(weeks(in: currentMonth)[weekIndex].indices, id: \.self) { dateIndex in
                        let date = weeks(in: currentMonth)[weekIndex][dateIndex]
                        if date != Date.distantPast {
                            dayView(for: date)
                        } else {
                            Spacer()
                                .frame(width: 47, height: 30)
                        }
                    }
                }
            }

            
            if isAddBtnClicked, selectedDate == nil {
                Text("select_date".localized)
                    .font(.montserratRegularFont(size: 14))
                    .foregroundColor(.red)
            } else if let selectedDate, selectedDate > Date().addingTimeInterval(100) {
                Text("select_past_date".localized)
                    .font(.montserratRegularFont(size: 14))
                    .foregroundColor(.red)
            } else {
                Spacer()
                    .frame(height: 44)
            }
            
            if let date = selectedDate {
                HStack {
                    let contactsMetOnTheDay = viewModel.contactsMetOn(date: date)
                    if !contactsMetOnTheDay.isEmpty {
                        ForEach(Array(contactsMetOnTheDay.enumerated()), id: \.element.id) { (index, contact) in
                            let isEnabled = !viewModel.checkIfContactBlockedMe(user: contact)
                            if let image = viewModel.contactsImages[contact.id] {
                                if isEnabled {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(Circle())
                                        .shadow(color: CustomColors.darkBlue, radius: 4)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(Circle())
                                        .shadow(color: CustomColors.darkBlue, radius: 4)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
            
            if isFromContactView {
                Button {
                    isAddBtnClicked = true
                    if let date = selectedDate, let id = contactId, isSelectedDateInThePast() {
                        Task {
                            await viewModel.addDate(date, with: id)
                        }
                    }
                } label: {
                    Text("save_date_button".localized.uppercased())
                        .font(.rubicBoldFont(size: 15))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(selectedDate != nil && isSelectedDateInThePast() ? .white : .black)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(selectedDate != nil && isSelectedDateInThePast() ? CustomColors.mainGradient : CustomColors.whiteGradient)
                                .shadow(color: .gray, radius: 2, x: 0, y: 1)
                        )
                }
                .padding(.horizontal)
            } else {
                HStack {
                    Spacer()
                    Button {
                        isAddBtnClicked = true
                        if let selectedDate, isSelectedDateInThePast()  {
                            viewModel.showCalendar = false
                            withAnimation {
                                viewModel.selectedDate = selectedDate
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            Text("add_date_button".localized.uppercased())
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }
}

struct GraphicalDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        GraphicalDatePicker(viewModel: ContactsViewModel(), testsViewModel: TestsViewModel(mainViewModel: MainViewModel()), currentMonth: Date(), isFromContactView: true, contactId: UUID(uuidString: "79295454-e8f0-11ed-a05b-0242ac120003")!)
    }
}
