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
    @StateObject private var onboardingViewModel = OnboardingViewModel()
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
                    if onboardingViewModel.shouldShowOnboarding {
                        OnboardingView1()
                            .environmentObject(authService)
                            .environmentObject(onboardingViewModel)
                    } else {
                        ContentView()
                            .environmentObject(appwriteService)
                            .environmentObject(authService)
                    }
                }
            }
            .onAppear {
                onboardingViewModel.checkOnboardingStatus(authService: authService)
            }
        }
    }
}
