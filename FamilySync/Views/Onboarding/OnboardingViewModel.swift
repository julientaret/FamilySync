//
//  OnboardingViewModel.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI
import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var shouldShowOnboarding: Bool = false
    @Published var isAuthenticated: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    func checkOnboardingStatus(authService: AuthService) {
        let hasSeenOnboarding = userDefaults.bool(forKey: hasSeenOnboardingKey)
        let isUserAuthenticated = authService.isAuthenticated
        
        // Afficher l'onboarding si :
        // 1. Première utilisation (n'a jamais vu l'onboarding)
        // 2. OU si l'utilisateur n'est pas authentifié
        shouldShowOnboarding = !hasSeenOnboarding || !isUserAuthenticated
        isAuthenticated = isUserAuthenticated
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
        shouldShowOnboarding = false
    }
    
    func handleAuthenticationSuccess() {
        isAuthenticated = true
        completeOnboarding()
    }
}
