//
//  SplashScreenViewModel.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI
import Foundation

@MainActor
class SplashScreenViewModel: ObservableObject {
    @Published var isFirstLaunch: Bool = false
    @Published var isLoading: Bool = false
    @Published var shouldNavigateToMain: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let firstLaunchKey = "hasLaunchedBefore"
    
    func checkFirstLaunch() {
        let hasLaunchedBefore = userDefaults.bool(forKey: firstLaunchKey)
        
        if !hasLaunchedBefore {
            // Première utilisation
            isFirstLaunch = true
            isLoading = false
        } else {
            // Pas première utilisation, on attend la connexion
            isFirstLaunch = false
            isLoading = true
        }
    }
    
    func checkAuthenticationStatus(authService: AuthService) {
        // Si ce n'est pas la première utilisation, on vérifie l'authentification
        if !isFirstLaunch {
            // Simuler un délai pour l'authentification
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
                
                await MainActor.run {
                    if authService.isAuthenticated {
                        shouldNavigateToMain = true
                        NotificationCenter.default.post(name: .splashScreenCompleted, object: nil)
                    } else {
                        // Si pas connecté, on peut afficher le bouton de connexion
                        isLoading = false
                    }
                }
            }
        }
    }
    
    func startApp() {
        // Marquer que l'app a été lancée
        userDefaults.set(true, forKey: firstLaunchKey)
        
        // Naviguer vers l'onboarding (pas directement vers l'écran principal)
        NotificationCenter.default.post(name: .splashScreenCompleted, object: nil)
    }
}
