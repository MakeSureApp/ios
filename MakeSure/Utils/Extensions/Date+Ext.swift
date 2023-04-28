//
//  Date+Ext.swift
//  MakeSure
//
//  Created by andreydem on 4/27/23.
//

import Foundation

extension Date {

    static func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
    
}
