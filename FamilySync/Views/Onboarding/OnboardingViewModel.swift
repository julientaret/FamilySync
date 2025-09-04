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
    @Published var currentOnboardingStep: Int = 1
    @Published var userName: String = ""
    @Published var userBirthday: Date = Date()
    
    // États pour la gestion des familles
    @Published var showCreateFamilyModal: Bool = false
    @Published var showJoinFamilyModal: Bool = false
    @Published var showInviteCodeModal: Bool = false
    @Published var currentFamily: Family?
    
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let userNameKey = "userName"
    private let userBirthdayKey = "userBirthday"
    
    func checkOnboardingStatus(authService: AuthService) {
        let hasSeenOnboarding = userDefaults.bool(forKey: hasSeenOnboardingKey)
        let isUserAuthenticated = authService.isAuthenticated
        
        // Afficher l'onboarding si :
        // 1. Première utilisation (n'a jamais vu l'onboarding)
        // 2. OU si l'utilisateur n'est pas authentifié
        shouldShowOnboarding = !hasSeenOnboarding || !isUserAuthenticated
        isAuthenticated = isUserAuthenticated
        
        // Charger les données utilisateur si elles existent
        if let savedName = userDefaults.string(forKey: userNameKey) {
            userName = savedName
        }
        if let savedBirthday = userDefaults.object(forKey: userBirthdayKey) as? Date {
            userBirthday = savedBirthday
        }
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
        shouldShowOnboarding = false
    }
    
    func handleAuthenticationSuccess() {
        isAuthenticated = true
        currentOnboardingStep = 2
    }
    
    func handleProfileSetup(name: String, birthday: Date) {
        userName = name
        userBirthday = birthday
        
        // Sauvegarder les données utilisateur
        userDefaults.set(name, forKey: userNameKey)
        userDefaults.set(birthday, forKey: userBirthdayKey)
        
        // Passer à l'étape suivante ou terminer l'onboarding
        currentOnboardingStep = 3
        completeOnboarding()
    }
    
    func nextStep() {
        currentOnboardingStep += 1
    }
    
    func previousStep() {
        if currentOnboardingStep > 1 {
            currentOnboardingStep -= 1
        }
    }
}
