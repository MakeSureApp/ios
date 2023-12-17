//
//  MakeSureApp.swift
//  MakeSure
//
//  Created by andreydem on 19.04.2023.
//

import SwiftUI
import OneSignalFramework

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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("Current configuration: \(BuildConfiguration.shared.environment)")
       // Remove this method to stop OneSignal Debugging
       OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
       // OneSignal initialization
        OneSignal.initialize(appEnvironment.onesignal_app_id, withLaunchOptions: launchOptions)

       // requestPermission will show the native iOS notification permission prompt.
       // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
       OneSignal.Notifications.requestPermission({ accepted in
         print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: true)
        
        UNUserNotificationCenter.current().delegate = self
            
       return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        

        let homeViewModel = appEnvironment.viewModelFactory.getHomeViewModel()
        homeViewModel.showNotificationsView = true
        completionHandler()
    }

}

