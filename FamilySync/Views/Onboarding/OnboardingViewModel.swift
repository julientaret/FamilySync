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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // États pour la gestion des familles
    @Published var showCreateFamilyModal: Bool = false
    @Published var showJoinFamilyModal: Bool = false
    @Published var showInviteCodeModal: Bool = false
    @Published var currentFamily: Family?
    
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let userNameKey = "userName"
    private let userBirthdayKey = "userBirthday"
    
    private let userDatabaseService = UserDatabaseService.shared
    
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
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Le nom ne peut pas être vide"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Récupérer l'ID de l'utilisateur depuis le service d'authentification
                guard let userId = AuthService.shared.currentUser?.id else {
                    await MainActor.run {
                        errorMessage = "Erreur: Utilisateur non connecté"
                        isLoading = false
                    }
                    return
                }
                
                // S'assurer que l'utilisateur existe en base
                let user = try await userDatabaseService.ensureUserExists(userId: userId)
                
                // Mettre à jour le profil avec le nom et la date de naissance
                let updatedUser = try await userDatabaseService.updateUserProfile(
                    userId: userId,
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    birthday: birthday
                )
                
                await MainActor.run {
                    userName = name
                    userBirthday = birthday
                    
                    // Sauvegarder les données utilisateur localement
                    userDefaults.set(name, forKey: userNameKey)
                    userDefaults.set(birthday, forKey: userBirthdayKey)
                    
                    // Passer à l'étape suivante ou terminer l'onboarding
                    currentOnboardingStep = 3
                    completeOnboarding()
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
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
