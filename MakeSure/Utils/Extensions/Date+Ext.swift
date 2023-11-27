//
//  Date+Ext.swift
//  MakeSure
//
//  Created by andreydem on 4/27/23.
//

import Foundation
import SwiftUI

extension Date {
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    var toString: String {
        let dateFormatter = DateFormatter()
        let currentLanguage = appEnvironment.localizationManager.getLanguage() == .RU ? "ru" : "en"
        dateFormatter.locale = Locale(identifier: currentLanguage)
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: self)
        let dateFormat = year == currentYear ? "dd MMM" : "dd MMM yyyy"
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: date, toGranularity: component)
    }
    
    var getAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: self, to: Date())
        let age = ageComponents.year!
        return age
    }
    
    var getMetDateBackgroundColor: Color {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: now)
        let daysSinceMet = components.day ?? 0

        if daysSinceMet <= 14 {
            return Color(red: 1, green: 64.0 / 255.0, blue: 156.0 / 255.0)
        } else if 15...29 ~= daysSinceMet {
            return Color(red: 247.0 / 255.0, green: 213.0 / 255.0, blue: 1)
        } else if 30...90 ~= daysSinceMet {
            return Color(red: 204.0 / 255.0, green: 199.0 / 255.0, blue: 1)
        } else {
            return Color(red: 181.0 / 255.0, green: 228.0 / 255.0, blue: 1)
        }
    }
    
    var getMetDateTextColor: Color {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: now)
        let daysSinceMet = components.day ?? 0

        if daysSinceMet <= 14 {
            return Color.white
        } else {
            return Color.black
        }
    }
}

extension Date? {
    
    var getMetDateString: String? {
        guard let self else { return nil }
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: self, to: now)
        let daysSinceMet = components.day ?? 0
        let monthsSinceMet = components.month ?? 0
        let yearsSinceMet = components.year ?? 0
        
        switch (daysSinceMet, monthsSinceMet, yearsSinceMet) {
        case (0, 0, 0):
            return "met_today".localized
        case (1, 0, 0):
            return "met_yesterday".localized
        case (2...6, 0, 0):
            return String(format: "met_x_days_ago".localized, daysSinceMet, daysSinceMet.localizedDayLabel)
        case (7...13, 0, 0):
            return "met_a_week_ago".localized
        case (14...20, 0, 0):
            return "met_two_weeks_ago".localized
        case (21...27, 0, 0):
            return "met_three_weeks_ago".localized
        case (28...31, 0, 0):
            return "met_four_weeks_ago".localized
        case (_, 1, 0):
            return "met_a_month_ago".localized
        case (_, 2..<12, 0):
            return String(format: "met_months_ago".localized, monthsSinceMet, monthsSinceMet.localizedMonthLabel)
        case (_, _, 1):
            return "met_a_year_ago".localized
        case (_, _, _):
            return String(format: "met_years_ago".localized, yearsSinceMet, yearsSinceMet.localizedYearLabel)
        }
    }
    
}

