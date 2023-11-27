//
//  ServerService.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.06.2023.
//

import Foundation

enum ServerServiceError: Error {
    case unexpectedError
    case networkError(Error)
    case decodingError(Error)
}

class ServerService {
    private let networkManager: NetworkManager
    private let urlSession: URLSession
    
    init() {
        self.networkManager = appEnvironment.networkManager
        self.urlSession = .shared
    }
    
//    func sendTest(imageData: Data) async throws -> TestDetectionResult {
//        var request = URLRequest(url: networkManager.getTestResultUrl())
//        request.httpMethod = "POST"
//
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        let body = createRequestBody(with: nil, boundary: boundary, data: imageData, mimeType: "image/jpg", filename: "test2.jpg")
//
//        let (data, response) = try await urlSession.upload(for: request, from: body)
//
//        print("data = \(data)\n response = \(response)")
//
//        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
//            throw ServerServiceError.unexpectedError
//        }
//
//        do {
//            let decoder = JSONDecoder()
//            let response = try decoder.decode(TestDetectionResult.self, from: data)
//            return response
//        } catch {
//            throw ServerServiceError.decodingError(error)
//        }
//    }
    
    func sendTest(imageData: Data) async throws -> TestDetectionResult {
        var request = URLRequest(url: networkManager.getTestResultUrl())
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createBody(boundary: boundary, data: imageData, mimeType: "image/jpeg", filename: "capturedImage.jpg")
        request.httpBody = body
        
        do {
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let (data, response) = try await session.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Code: \(httpResponse.statusCode)")
                }
                
                // Print the raw response for debugging
                if let responseData = String(data: data, encoding: .utf8) {
                    print("Response Data: \(responseData)")
                }

                // Decode the data
                let result = try JSONDecoder().decode(TestDetectionResult.self, from: data)
                return result
            } catch {
                print("Error encountered: \(error)")
                throw error
            }
    }
    
    private func createBody(boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"img\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        return body
    }


    private func createRequestBody(with parameters: [String: String]?, boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        var body = Data()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"img\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        return body
    }
    
}
