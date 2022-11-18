//
//  SnacktacularApp.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 07.11.22.
//

import SwiftUI

import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
} // AppDelegate


@main
struct SnacktacularApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var spotVM = SpotViewModel()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(spotVM)
        }
    }
}
