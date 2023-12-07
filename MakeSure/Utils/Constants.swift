//
//  Constants.swift
//  MakeSure
//
//  Created by Macbook Pro on 28.11.2023.
//

import Foundation

struct Constants {
    static let privacyUrl = URL(string: "https://makesure.app/confidentiality")
    static let helpUrl = URL(string: "https://makesure.app/faq")
    static let agreementUrl = URL(string: "https://makesure.app/license_agreement")
    static let supabaseUrl = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "http://default-supabase-url.com")!
    static let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""
    static let supabaseServiceKey = ProcessInfo.processInfo.environment["SUPABASE_SERVICE_KEY"] ?? ""
    static let serverUrl = URL(string: ProcessInfo.processInfo.environment["SERVER_URL"] ?? "http://default-server-url.com")!
    static let smsServiceUrl = ProcessInfo.processInfo.environment["SMS_SERVICE_URL"] ?? "http://default-sms-service-url.com"
    static let smsServiceEmail = ProcessInfo.processInfo.environment["SMS_SERVICE_EMAIL"] ?? "default@email.com"
    static let smsServiceApiKey = ProcessInfo.processInfo.environment["SMS_SERVICE_API_KEY"] ?? ""
}
