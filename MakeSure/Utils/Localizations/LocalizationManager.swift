//
//  LocalizationManager.swift
//  MakeSure
//
//  Created by andreydem on 5/13/23.
//

import Foundation

class LocalizationManager {
    
    private var currentLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    func getLanguage() -> AvailableLanguages {
        for language in AvailableLanguages.allCases {
            if language.key == currentLanguage {
                return language
            }
        }
        return .EN
    }
    
    func setLanguage(_ language: String) {
        guard Bundle.main.path(forResource: language, ofType: "lproj") != nil else {
            // Handle invalid language code
            return
        }
        currentLanguage = language
    }
    
    func localizedString(forKey key: String) -> String {
        let languageBundle = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        let bundle = Bundle(path: languageBundle ?? Bundle.main.path(forResource: "en", ofType: "lproj")!)
        return NSLocalizedString(key, bundle: bundle!, comment: "")
    }

}
