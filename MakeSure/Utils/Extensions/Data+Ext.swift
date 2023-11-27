//
//  Data+Ext.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.06.2023.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
