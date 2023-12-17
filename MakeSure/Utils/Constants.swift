//
//  Constants.swift
//  MakeSure
//
//  Created by Macbook Pro on 28.11.2023.
//

import Foundation

struct Constants {
    static let buildConfig = BuildConfiguration.shared
    static let privacyUrl = URL(string: "https://makesure.app/confidentiality")
    static let helpUrl = URL(string: "https://makesure.app/faq")
    static let agreementUrl = URL(string: "https://makesure.app/license_agreement")
    static let supabaseUrl = URL(string: buildConfig.value(forKey: "SUPABASE_URL") ?? "http://default-supabase-url.com")!
    static let supabaseKey = buildConfig.value(forKey: "SUPABASE_KEY") ?? ""
    static let supabaseServiceKey = buildConfig.value(forKey: "SUPABASE_SERVICE_KEY") ?? ""
    static let serverUrl = URL(string: buildConfig.value(forKey: "SERVER_URL") ?? "http://default-server-url.com")!
    static let smsServiceUrl = buildConfig.value(forKey: "SMS_SERVICE_URL") ?? "http://default-sms-service-url.com"
    static let smsServiceEmail = buildConfig.value(forKey: "SMS_SERVICE_EMAIL") ?? "default@email.com"
    static let smsServiceApiKey = buildConfig.value(forKey: "SMS_SERVICE_API_KEY") ?? ""
}
