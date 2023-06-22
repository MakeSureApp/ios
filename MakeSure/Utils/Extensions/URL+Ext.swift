//
//  URL+EXt.swift
//  MakeSure
//
//  Created by Macbook Pro on 21.06.2023.
//

import Foundation

enum DeeplinkNavigation: Hashable {
  case profile, setUsername
  case addContact(String)
}

extension URL {
    var isDeeplink: Bool {
        return scheme == "MakeSure"
    }
    
    var deeplinkNavigation: DeeplinkNavigation? {
        guard isDeeplink else { return nil }
    
        
        switch host {
        case "profile": return .profile
        case "pick": return .setUsername
        case "add":
            let userId = lastPathComponent
            return .addContact(userId)
        default: return nil
        }
    }
}
