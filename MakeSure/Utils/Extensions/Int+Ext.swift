//
//  Int+Ext.swift
//  MakeSure
//
//  Created by andreydem on 5/13/23.
//

import Foundation

extension Int {
    
    var localizedDayLabel: String {
        let lastDigit = self % 10
        let secondLastDigit = (self / 10) % 10
        
        if secondLastDigit != 1 {
            switch lastDigit {
            case 1:
                return "день"
            case 2, 3, 4:
                return "дня"
            default:
                return "дней"
            }
        }
        
        return "дней"
    }
    
    var localizedYearLabel: String {
        let yearsString: String
        let yearsSinceMet = self
        if (yearsSinceMet % 10 == 1 && yearsSinceMet % 100 != 11) {
            yearsString = "год"
        } else if (yearsSinceMet % 10 >= 2 && yearsSinceMet % 10 <= 4 && (yearsSinceMet % 100 < 10 || yearsSinceMet % 100 >= 20)) {
            yearsString = "года"
        } else {
            yearsString = "лет"
        }
        return yearsString
    }
    
    var localizedMonthLabel: String {
        let monthsSinceMet = self
        let monthsString: String
        if (monthsSinceMet % 10 == 1 && monthsSinceMet % 100 != 11) {
            monthsString = "месяц"
        } else if (monthsSinceMet % 10 >= 2 && monthsSinceMet % 10 <= 4 && (monthsSinceMet % 100 < 10 || monthsSinceMet % 100 >= 20)) {
            monthsString = "месяца"
        } else {
            monthsString = "месяцев"
        }
        
        return monthsString
    }
    
    var russianAgeSuffix: String {
            switch self % 100 {
            case 11...14:
                return "лет"
            default:
                switch self % 10 {
                case 1:
                    return "год"
                case 2...4:
                    return "года"
                default:
                    return "лет"
                }
            }
        }
    
    var russianSecondsSuffix: String {
           switch self % 100 {
           case 11...14:
               return "секунд"
           default:
               switch self % 10 {
               case 1:
                   return "секунда"
               case 2...4:
                   return "секунды"
               default:
                   return "секунд"
               }
           }
       }
}
