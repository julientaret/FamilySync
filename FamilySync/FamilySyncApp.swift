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
                        // Navigation entre les vues d'onboarding basée sur l'étape actuelle
                        switch onboardingViewModel.currentOnboardingStep {
                        case 1:
                            OnboardingView1()
                                .environmentObject(authService)
                                .environmentObject(onboardingViewModel)
                        case 2:
                            OnboardingView2()
                                .environmentObject(authService)
                                .environmentObject(onboardingViewModel)
                        case 3:
                            OnboardingView3()
                                .environmentObject(authService)
                                .environmentObject(onboardingViewModel)
                        case 4:
                            OnboardingView4(onboardingViewModel: onboardingViewModel)
                                .environmentObject(authService)
                                .environmentObject(onboardingViewModel)
                        default:
                            OnboardingView1()
                                .environmentObject(authService)
                                .environmentObject(onboardingViewModel)
                        }
                    } else {
                        ContentView()
                            .environmentObject(appwriteService)
                            .environmentObject(authService)
                    }
                }
            }
            .onAppear {
                print("🚨 [ALERT] FamilySyncApp onAppear!")
                Task {
                    await onboardingViewModel.checkOnboardingStatusAsync(authService: authService)
                }
            }
        }
    }
}
