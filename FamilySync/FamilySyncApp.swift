//
//  FamilySyncApp.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

@main
struct FamilySyncApp: App {
    @StateObject private var appwriteService = AppwriteService.shared
    @StateObject private var authService = AuthService.shared
    @State private var showSplashScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    SplashScreenView()
                        .environmentObject(appwriteService)
                        .environmentObject(authService)
                        .onReceive(NotificationCenter.default.publisher(for: .splashScreenCompleted)) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplashScreen = false
                            }
                        }
                } else {
                    ContentView()
                        .environmentObject(appwriteService)
                        .environmentObject(authService)
                }
            }
        }
    }
}
