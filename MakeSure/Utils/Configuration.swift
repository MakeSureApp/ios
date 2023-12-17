//
//  Configuration.swift
//  MakeSure
//
//  Created by Macbook Pro on 16.12.2023.
//

import Foundation

enum BuildEnvironment: String {
    case debugDevelopment = "Debug Development"
    case releaseDevelopment = "Release Development"

    case debugStaging = "Debug Staging"
    case releaseStaging = "Release Staging"

    case debugProduction = "Debug Production"
    case releaseProduction = "Release Production"
}

class BuildConfiguration {
    static let shared = BuildConfiguration()
    
    var environment: BuildEnvironment
    private var configDict: [String: Any]?
    
    init() {
        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        
        environment = BuildEnvironment(rawValue: currentConfiguration)!
        
        let plistName: String
        switch environment {
        case .debugDevelopment, .releaseDevelopment:
            plistName = "Development"
        case .debugStaging, .releaseStaging:
            plistName = "Staging"
        case .debugProduction, .releaseProduction:
            plistName = "Production"
        }
        
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            configDict = dict
        }
    }
    
    func value(forKey key: String) -> String? {
        return configDict?[key] as? String
    }
}
