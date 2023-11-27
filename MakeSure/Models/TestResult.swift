//
//  TestResult.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.06.2023.
//

import Foundation

struct TestResult: Decodable {
    let id: Int
    let isActivated: Bool
    let package_id: Int
    let result: Bool
}

struct TestDetectionResult: Decodable {
    let error_code: String?
    let id: String?
    let isActivated: Bool?
    let package_id: String?
    let result: String?
    let test_type: String?
}
