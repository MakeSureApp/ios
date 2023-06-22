//
//  MakeSureApp.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI

private struct DeeplinkNavigationKey: EnvironmentKey {
    static let defaultValue: DeeplinkNavigation? = nil
}

extension EnvironmentValues {
    var deeplinkNavigation: DeeplinkNavigation? {
        get { self[DeeplinkNavigationKey.self] }
        set { self[DeeplinkNavigationKey.self] = newValue }
    }
}

@main
struct MakeSureApp: App {
    
    @State private var deeplinkNavigation: DeeplinkNavigation? = nil
    @ObservedObject private var deeplinkHandler = appEnvironment.deeplinkHandler
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.colorScheme, .light)
                .environment(\.deeplinkNavigation, deeplinkNavigation)
                .onOpenURL { url in
                    deeplinkHandler.deeplinkNavigation = url.deeplinkNavigation
                }
        }
    }
    
}
