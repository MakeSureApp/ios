//
//  String+Ext.swift
//  MakeSure
//
//  Created by andreydem on 20.04.2023.
//

import Foundation
import SwiftUI

extension String {
    
    var isNumeric: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            }
            else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var isValidFirstName: Bool {
        guard self.count > 2, self.count < 18 else { return false }

        let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Zа-яА-Я].*[a-zA-Zа-яА-Я]$)([^ ]?))$")
        return predicateTest.evaluate(with: self)
    }
    
    var isValidBirthdayDate: Bool {
        if self.count == 8 {
            let dateString = self.dateStringFromDateInput
            
            if let userBirthday = dateString.dateFromString {
                let hundredYearsAgo = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
                let sixteenYearsAgo = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
                return userBirthday > hundredYearsAgo && userBirthday <= sixteenYearsAgo
            }
        }
        return false
    }
    
    var dateStringFromDateInput: String {
        var dateString = self
        dateString.insert(":", ind: 2)
        dateString.insert(":", ind: 5)
        return dateString
    }
    
    var dateFromString: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd:MM:yyyy"
        
        return dateFormatter.date(from: self)
    }
    
    mutating func insert(_ string: String, ind: Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: ind) )
    }
    
    mutating func removePlusPrefix() {
        if self.hasPrefix("+") {
            self = String(self.dropFirst())
        }
    }
    
    var localized: String {
        return appEnvironment.localizationManager.localizedString(forKey: self)
    }
    
}
