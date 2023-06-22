//
//  AppleSignIn.swift
//  MakeSure
//
//  Created by Macbook Pro on 14.06.2023.
//

import Foundation
import CryptoKit
import AuthenticationServices

struct SignInAppleResult {
    let idToken: String
    let nonce: String
}

class AppleSignIn: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInAppleResult, Error>) -> Void)?
    var loginError: Error?
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }


    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    func signInWithApple(completion: @escaping (Result<SignInAppleResult, Error>) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    private func getUserFromAppleIDCredential(_ credential: ASAuthorizationAppleIDCredential) -> UserApple {
        return UserApple(
            id: credential.user,
            email: credential.email ?? "",
            firstName: credential.fullName?.givenName ?? "",
            lastName: credential.fullName?.familyName ?? ""
        )
    }
        
}

extension AppleSignIn: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce, let completion = completionHandler else {
                return
            }
            
            if let identityTokenData = appleIDCredential.identityToken,
               let identityToken = String(data: identityTokenData, encoding: .utf8) {
                let appleResult = SignInAppleResult(idToken: identityToken, nonce: nonce)
                completion(.success(appleResult))
            } else {
                completion(.failure(NSError()))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.loginError = error
    }
}

