//
//  OrderBoxAddressAndDelivery.swift
//  MakeSure
//
//  Created by Macbook Pro on 25.11.2023.
//

import SwiftUI

struct OrderBoxAddressAndDeliveryView: View {
    
    @State private var text: String = ""
    @FocusState private var isInputActive: Bool
    @State private var isPickerPresented = false
    @State private var selectedNumber = 1
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image("arrowIcon")
                        .resizable()
                        .rotationEffect(.degrees(180))
                        .frame(width: 8, height: 14)
                }
                Spacer()
                Text("адрес и доставка")
                    .font(.montserratBoldFont(size: 18))
                    .foregroundStyle(.black)
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("населенный пункт")
                                .font(.montserratBoldFont(size: 22))
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        HStack {
                            Text("г. Москва")
                                .font(.montserratRegularFont(size: 12))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    VStack(spacing: 10) {
                        HStack {
                            Text("адрес")
                                .font(.montserratBoldFont(size: 22))
                                .foregroundStyle(.black)
                            Spacer()
                            Image("arrowIcon")
                                .resizable()
                                .frame(width: 8, height: 14)
                        }
                        HStack {
                            Text("ул. Костякова, д. 8/6, кв. 146")
                                .font(.montserratRegularFont(size: 12))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    VStack(spacing: 10) {
                        HStack {
                            Text("комментарий")
                                .font(.montserratBoldFont(size: 22))
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        CustomUnderlinedView(color: CustomColors.darkGray, height: 0.2) {
                            TextField("информация для курьера", text: $text)
                                .padding(4)
                                .focused($isInputActive)
                                .font(.montserratRegularFont(size: 12))
                        }
                    }
                    VStack(spacing: 12) {
                        HStack {
                            Text("дата и время доставки")
                                .font(.montserratBoldFont(size: 22))
                                .foregroundStyle(.black)
                            Spacer()
                        }
                        WeekView()
                        TimeSlotView()
                    }
                    HStack {
                        Text("количество")
                            .font(.montserratBoldFont(size: 22))
                            .foregroundStyle(.black)
                        Button(action: {
                            withAnimation {
                                isPickerPresented = true
                            }
                        }) {
                            HStack {
                                Text("\(selectedNumber)")
                                    .font(.montserratRegularFont(size: 16))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    OrderBoxSummarySectionView()
                    RoundedGradientButton(text: "continue_button".localized.uppercased(), isEnabled: true) {
                        isInputActive = false
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 20)
        .overlay(
            BottomSheetView(isPresented: $isPickerPresented, selectedNumber: $selectedNumber)
        )
        .onTapGesture {
            isPickerPresented = false
        }
    }
    
    private func monthName(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
}

struct WeekView: View {
    @State private var selectedDay: Date?
    private let calendar = Calendar.current
    private var days: [String] {
        [
            "sunday_short".localized,
            "monday_short".localized,
            "tuesday_short".localized,
            "wednesday_short".localized,
            "thursday_short".localized,
            "friday_short".localized,
            "saturday_short".localized
        ]
    }
    
    private var week: [Date] {
        let today = calendar.startOfDay(for: Date())
        guard let nextWeekStart = calendar.date(byAdding: .day, value: 1, to: today) else {
            return []
        }
        return (1...7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: nextWeekStart)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 6)
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 4, y: 2)
                .shadow(color: .gray.opacity(0.1), radius: 2, x: -4, y: 2)
            
            VStack {
                HStack {
                    Text(displayedMonthName())
                        .font(.montserratBoldFont(size: 12))
                        .foregroundStyle(.black)
                        .padding(.top)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
                
                HStack {
                    ForEach(week, id: \.self) { day in
                        VStack {
                            Text(dayOfWeek(for: day))
                                .font(.montserratBoldFont(size: 10))
                                .foregroundStyle(.gray)
                            Text("\(calendar.component(.day, from: day))")
                                .font(.montserratBoldFont(size: 12))
                                .foregroundStyle(day == selectedDay ? .white : .black)
                                .padding(8)
                                .background(day == selectedDay ? Color.purple : Color.clear)
                                .clipShape(Circle())
                                .padding(3)
                                .foregroundColor(day == selectedDay ? .white : .black)
                                .onTapGesture {
                                    selectedDay = day
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 6)
            }
        }
        .frame(height: 120)
        .padding(.horizontal, 2)
    }
    
    private func displayedMonthName() -> String {
        if let selectedDay = selectedDay {
            return monthYearString(for: selectedDay)
        } else {
            let firstDate = week.first!
            let lastDate = week.last!
            return monthName(for: firstDate, endDate: lastDate)
        }
    }
    
    private func monthYearString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func monthName(for startDate: Date, endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        let startMonthName = dateFormatter.string(from: startDate)
        let endMonthName = dateFormatter.string(from: endDate)
        
        dateFormatter.dateFormat = "yyyy"
        let startYear = dateFormatter.string(from: startDate)
        let endYear = dateFormatter.string(from: endDate)
        
        if startMonthName == endMonthName {
            return "\(startMonthName) \(startYear)"
        } else if startYear == endYear {
            return "\(startMonthName) - \(endMonthName) \(startYear)"
        } else {
            return "\(startMonthName) \(startYear) - \(endMonthName) \(endYear)"
        }
    }

    
    private func dayOfWeek(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        return days[weekday - 1]
    }
}

struct TimeSlotView: View {
    let timeSlots = ["10:00 – 13:00", "13:00 – 16:00", "16:00 – 19:00", "19:00 – 22:00"]
    @State private var selectedSlot: String?

    var body: some View {
        HStack {
            ForEach(timeSlots, id: \.self) { slot in
                Button(action: {
                    selectedSlot = slot
                }) {
                    Text(slot)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .font(.montserratRegularFont(size: 10))
                        .background(selectedSlot == slot ? Color.purple : Color.white)
                        .foregroundColor(selectedSlot == slot ? Color.white : Color.black)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: selectedSlot == slot ? 0 : 1)
                        )
                }
            }
        }
    }
}

struct BottomSheetView: View {
    @Binding var isPresented: Bool
    @Binding var selectedNumber: Int
    let maxHeight = UIScreen.main.bounds.height / 3

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Button("ГОТОВО") {
                    withAnimation {
                        isPresented = false
                    }
                }
                .font(.montserratBoldFont(size: 16))
                .foregroundStyle(.white)
                .padding()

                Picker("Select a number", selection: $selectedNumber) {
                    ForEach(1...10, id: \.self) { number in
                        Text("\(number)")
                            .tag(number)
                            .font(.montserratBoldFont(size: 20))
                            .foregroundStyle(.white)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
            }
            .frame(maxHeight: maxHeight)
            .background(Color.gradientDarkBlue)
            .cornerRadius(20)
            .offset(y: isPresented ? 0 : maxHeight)
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.spring(), value: isPresented)
    }
}

#Preview {
    OrderBoxAddressAndDeliveryView()
}
