//
//  TestView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct TestsView: View {
    @EnvironmentObject var viewModel: TestsViewModel
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    orderNewBoxView
                    HStack {
                        Text("my_tests_section".localized)
                            .font(.montserratBoldFont(size: 25))
                            .foregroundColor(.white)
                            .padding(.bottom)
                        Spacer()
                    }
                    TestsCalendarScrollView(viewModel: viewModel)
                    if viewModel.isLoading {
                        RotatingShapesLoader(animate: $isAnimating)
                            .frame(maxWidth: 100)
                            .padding(.top, 50)
                            .onAppear {
                                isAnimating = true
                            }
                            .onDisappear {
                                isAnimating = false
                            }
                    } else if viewModel.hasLoaded {
                        testsBoxes
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("no_tests_found".localized)
                                .font(.montserratRegularFont(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                            Text("order_test_message".localized)
                                .font(.montserratRegularFont(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    Spacer()
                        .frame(height: 40)
                }
            }
            .padding(.horizontal, 20)
        }
        .task {
            await viewModel.fetchTests()
            await contactsViewModel.fetchContacts()
        }
    }
}

private extension TestsView {
    var orderNewBoxView: some View {
        ZStack {
            Image("orderNewBoxTestsCardImage")
                .resizable()
                .frame(height: 75)
                .cornerRadius(10)
            HStack {
                VStack(alignment: .leading) {
                    Text("order_new_box".localized)
                        .font(.montserratMediumFont(size: 18))
                        .foregroundColor(.white)
                    Text("1 490 руб.")
                        .font(.montserratBoldFont(size: 11))
                        .foregroundColor(.white)
                }
                .padding(.leading, 30)
                Spacer()
                Image("orderBoxImage")
                    .resizable()
                    .frame(width: 185, height: 130)
                    .padding(.bottom, -16)
                    .padding(.trailing, -8)
            }
        }
        .onTapGesture {
            withAnimation {
                viewModel.mainViewModel.showOrderBoxView = true
            }
        }
    }
}

struct TestDayView: View {
    let day: String
    let date: String
    let isTest: Bool
    let isNegative: Bool?
    let isToday: Bool

    var body: some View {
        VStack {
            Text(day)
                .font(.montserratRegularFont(size: 12))
                .foregroundColor(.white)
                .padding(2)
            if isToday {
                ZStack {
                    ZStack(alignment: .center) {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text(date)
                            .font(.montserratRegularFont(size: 12))
                            .padding(.horizontal, 8)
                            .foregroundColor(.black)
                        
                    }
                    .padding(.top, -3)
                }
            }
            if !isTest, !isToday {
                Text(date)
                    .font(.montserratRegularFont(size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
            } else if let isNegative {
                ZStack {
                    ZStack(alignment: .center) {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(isNegative ? .lightGreen : .orange)
                            .overlay {
                                Circle()
                                    .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                            }
                        
                        Text(date)
                            .font(.montserratRegularFont(size: 12))
                            .padding(.horizontal, 8)
                            .foregroundColor(.black)
                        
                    }
                    .padding(.top, -3)
                }
            }
        }
        .frame(height: 50)
        .padding(6)
    }
}

struct TestsCalendarScrollView: View {
    @ObservedObject var viewModel: TestsViewModel
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

    @State private var currentDate = Date().endOfWeek ?? Date()

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
                            let isNegativeTest = viewModel.isNegativeTestOn(date: date)
                            TestDayView(day: dayOfWeek, date: dateString, isTest: isNegativeTest != nil, isNegative: isNegativeTest, isToday: date.hasSame(.day, as: Date()))
                                .id("\(weeksAgo)-\(dayOffset)")
                                .onTapGesture {
                                    viewModel.dateToStartInCalendar = date
                                    viewModel.showTestsCalendar.toggle()
                                }
                        }
                    }
                }
                .frame(height: 50)
                .padding(.bottom)
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

private extension TestsView {
    var testsBoxes: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.lastTests.isEmpty {
                if let date = viewModel.lastTests.first?.date {
                    HStack {
                        Spacer()
                        Text(date.toString)
                            .font(.montserratMediumFont(size: 20))
                            .foregroundColor(.white)
                            .padding(4)
                        Spacer()
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.lastTests) { test in
                        TestView(test: test)
                    }
                }
            }
            ForEach(viewModel.uniqueDateRanges(), id: \.self) { rangeString in
                VStack(alignment: .leading) {
                    Text(rangeString)
                        .font(.montserratLightFont(size: 16))
                        .foregroundColor(.white)
                    ForEach(Array(viewModel.groupedTests.keys.sorted().reversed()), id: \.self) { date in
                        if viewModel.dateGroupString(date: date) == rangeString,
                           let tests = viewModel.groupedTests[date] {
                            TestGroupView(date: date, tests: tests)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct TestView: View {
    let test: TestModel
    var body: some View {
        VStack {
            HStack {
                Circle()
                    .frame(width: 18, height: 18)
                    .foregroundColor(test.result == "negative" ? .lightGreen : .orange)
                Text(test.name)
                    .font(.montserratLightFont(size: 15))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                Spacer()
                Text(test.result == "negative" ? "negative_result".localized : "failure_result".localized)
                    .font(.montserratLightFont(size: 15))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TestGroupView: View {
    let date: Date
    let tests: [TestModel]

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Circle()
                        .frame(width: 18, height: 18)
                        .foregroundColor(tests.allSatisfy { $0.result == "negative" } ? .lightGreen : .orange)
                    Text("STD Test")
                        .font(.interMediumFont(size: 13))
                        .foregroundColor(.black)
                    Spacer()
                    if let date = tests.first?.date {
                        Text(date.toString)
                            .font(.interRegularFont(size: 11))
                            .foregroundColor(.black)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(.white)
            .cornerRadius(12)
            
            if isExpanded {
                if let date = tests.first?.date {
                    HStack {
                        Spacer()
                        Text(date.toString)
                            .font(.montserratMediumFont(size: 20))
                            .foregroundColor(.white)
                            .padding(4)
                        Spacer()
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(tests) { test in
                        TestView(test: test)
                    }
                }
                .padding(8)
                .padding(.bottom, 12)
                .transition(.opacity)
            }
        }
    }
}

struct TestsView_Previews: PreviewProvider {
    static var previews: some View {
        TestsView()
            .environmentObject(TestsViewModel(mainViewModel: MainViewModel()))
            .environmentObject(ContactsViewModel())
    }
}
