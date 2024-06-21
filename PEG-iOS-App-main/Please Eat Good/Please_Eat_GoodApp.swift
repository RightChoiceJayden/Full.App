//
//  Please_Eat_GoodApp.swift
//  Please Eat Good
//
//  Created by Christopher on 3/10/21.
//

import SwiftUI
import Firebase
import SwiftyStoreKit

let db = Firestore.firestore()

@main
struct Please_Eat_GoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(SessionStore())
                .environmentObject(ProfileStore())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
