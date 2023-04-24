//
//  CountryCodes.swift
//  MakeSure
//
//  Created by andreydem on 22.04.2023.
//

import Foundation

enum CountryCode: String, CaseIterable {
    case US = "+1"
    case RU = "+7"
    case DE = "+49"
    case GB = "+44"
    case FR = "+33"
    case IT = "+39"
    case ES = "+34"
    case NL = "+31"
    case BE = "+32"
    case PL = "+48"
    case SE = "+46"
    case NO = "+47"
    case FI = "+358"
    case DK = "+45"
    case PT = "+351"
    case CH = "+41"
    case AT = "+43"
    case IE = "+353"
    case LU = "+352"
    case MX = "+52"
    case BR = "+55"
    case AR = "+54"
    case CL = "+56"
    case CO = "+57"
    case PE = "+51"
    case VE = "+58"
    case MY = "+60"
    case AU = "+61"
    case NZ = "+64"

    var description: String {
        switch self {
        case .US: return "US \(self.rawValue)"
        case .RU: return "RU \(self.rawValue)"
        case .DE: return "DE \(self.rawValue)"
        case .GB: return "GB \(self.rawValue)"
        case .FR: return "FR \(self.rawValue)"
        case .IT: return "IT \(self.rawValue)"
        case .ES: return "ES \(self.rawValue)"
        case .NL: return "NL \(self.rawValue)"
        case .BE: return "BE \(self.rawValue)"
        case .PL: return "PL \(self.rawValue)"
        case .SE: return "SE \(self.rawValue)"
        case .NO: return "NO \(self.rawValue)"
        case .FI: return "FI \(self.rawValue)"
        case .DK: return "DK \(self.rawValue)"
        case .PT: return "PT \(self.rawValue)"
        case .CH: return "CH \(self.rawValue)"
        case .AT: return "AT \(self.rawValue)"
        case .IE: return "IE \(self.rawValue)"
        case .LU: return "LU \(self.rawValue)"
        case .MX: return "MX \(self.rawValue)"
        case .BR: return "BR \(self.rawValue)"
        case .AR: return "AR \(self.rawValue)"
        case .CL: return "CL \(self.rawValue)"
        case .CO: return "CO \(self.rawValue)"
        case .PE: return "PE \(self.rawValue)"
        case .VE: return "VE \(self.rawValue)"
        case .MY: return "MY \(self.rawValue)"
        case .AU: return "AU \(self.rawValue)"
        case .NZ: return "NZ \(self.rawValue)"
        }
    }
}
