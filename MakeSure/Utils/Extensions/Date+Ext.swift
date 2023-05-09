//
//  Date+Ext.swift
//  MakeSure
//
//  Created by andreydem on 4/27/23.
//

import Foundation

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
        dateFormatter.locale = Locale.current
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
}
