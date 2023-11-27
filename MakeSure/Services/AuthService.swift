//
//  AuthService.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Combine
import Foundation

enum AuthType {
    case signIn
    case signUp
}

class AuthService: ObservableObject {
    
    enum AuthState {
        case isLoggedIn(UserModel)
        case isLoggedOut
    }
    
    private static let userKey = "loggedInUser"
    
    @Published var authState: AuthState
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        //authState = .isLoggedOut
        //authState = .isLoggedIn(UserModel(id: UUID(), name: "Joyce", birthdate: Date(), sex: "female", phone: "+79001234567"))
        if let user = AuthService.getUserFromUserDefaults() {
            authState = .isLoggedIn(user)
        } else {
            authState = .isLoggedOut
        }
        
        $authState.sink { [weak self] state in
            switch state {
            case .isLoggedIn(let user):
                self?.saveUserToUserDefaults(user: user)
            case .isLoggedOut:
                self?.removeUserFromUserDefaults()
            }
        }
        .store(in: &cancellables)
    }
    
    private let baseURL = "https://@gate.smsaero.ru/v2/sms/send"
    private var generatedCode: String?
    
    private let email = "technical@makesure.app"
    private let apiKey = "KlU96stD5nD66t2eJyxZFmqNw1aJ"
    
    func sendSMS(to number: String) {
        let code = generateRandomCode()
        generatedCode = code
        var formattedNumber = number
        formattedNumber.removePlusPrefix()
        
        let encodedNumber = formattedNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedText = code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedSign = "SMS Aero".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "\(baseURL)?number=\(encodedNumber)&text=\(encodedText)&sign=\(encodedSign)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let loginString = "\(email):\(apiKey)"
        if let data = loginString.data(using: .utf8) {
            let base64LoginString = data.base64EncodedString()
            request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send SMS: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Failed to send SMS with status code: \(httpResponse.statusCode)")
                return
            }
            print("SMS sent successfully")
        }.resume()
    }
    
    private func generateRandomCode() -> String {
        return String(format: "%06d", Int.random(in: 100_000...999_999))
    }
    
    func isCodeValid(_ code: String) -> Bool {
        return code == generatedCode
    }
    
    private func saveUserToUserDefaults(user: UserModel) {
        if let encodedData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedData, forKey: AuthService.userKey)
        }
    }
    
    private func removeUserFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: AuthService.userKey)
    }
    
    private static func getUserFromUserDefaults() -> UserModel? {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            return user
        }
        return nil
    }
}
