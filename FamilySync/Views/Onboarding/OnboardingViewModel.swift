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
    private let familyDatabaseService = FamilyDatabaseService.shared
    
    func checkOnboardingStatus(authService: AuthService) {
        print("🚨 [ALERT] checkOnboardingStatus appelée!")
        let hasSeenOnboarding = userDefaults.bool(forKey: hasSeenOnboardingKey)
        let isUserAuthenticated = authService.isAuthenticated
        
        print("🚨 [ALERT] hasSeenOnboarding: \(hasSeenOnboarding)")
        print("🚨 [ALERT] isUserAuthenticated: \(isUserAuthenticated)")
        
        // Afficher l'onboarding si :
        // 1. Première utilisation (n'a jamais vu l'onboarding)
        // 2. OU si l'utilisateur n'est pas authentifié
        shouldShowOnboarding = !hasSeenOnboarding || !isUserAuthenticated
        isAuthenticated = isUserAuthenticated
        
        print("🚨 [ALERT] shouldShowOnboarding: \(shouldShowOnboarding)")
        
        // Si l'utilisateur est authentifié et doit voir l'onboarding, initialiser les données
        if isUserAuthenticated && shouldShowOnboarding {
            print("🚨 [ALERT] Appel de initializeOnboarding()")
            Task {
                await initializeOnboarding()
            }
        }
    }
    
    /// Version asynchrone qui attend que l'authentification soit vérifiée
    func checkOnboardingStatusAsync(authService: AuthService) async {
        print("🚨 [ALERT] checkOnboardingStatusAsync appelée!")
        
        // Attendre un peu pour que checkExistingSession() se termine
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
        
        let hasSeenOnboarding = userDefaults.bool(forKey: hasSeenOnboardingKey)
        let isUserAuthenticated = authService.isAuthenticated
        
        print("🚨 [ALERT] checkOnboardingStatusAsync - hasSeenOnboarding: \(hasSeenOnboarding)")
        print("🚨 [ALERT] checkOnboardingStatusAsync - isUserAuthenticated: \(isUserAuthenticated)")
        
        // Afficher l'onboarding si :
        // 1. Première utilisation (n'a jamais vu l'onboarding)
        // 2. OU si l'utilisateur n'est pas authentifié
        shouldShowOnboarding = !hasSeenOnboarding || !isUserAuthenticated
        isAuthenticated = isUserAuthenticated
        
        print("🚨 [ALERT] checkOnboardingStatusAsync - shouldShowOnboarding: \(shouldShowOnboarding)")
        
        // Si l'utilisateur est authentifié et doit voir l'onboarding, initialiser les données
        if isUserAuthenticated && shouldShowOnboarding {
            await initializeOnboarding()
        }
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
        userDefaults.set(userName, forKey: userNameKey)
        userDefaults.set(userBirthday, forKey: userBirthdayKey)
        shouldShowOnboarding = false
        isAuthenticated = true
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
                _ = try await userDatabaseService.ensureUserExists(userId: userId)
                
                // Mettre à jour le profil avec le nom et la date de naissance
                _ = try await userDatabaseService.updateUserProfile(
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
                    
                    // Passer à l'étape 4 (récapitulatif)
                    currentOnboardingStep = 4
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
    
    /// Vérifie si l'utilisateur est déjà dans une famille
    func isUserInFamily() -> Bool {
        return currentFamily != nil
    }
    
    /// Vérifie si l'utilisateur est déjà dans une famille (version asynchrone)
    func isUserInFamilyAsync() async -> Bool {
        guard let userId = AuthService.shared.currentUser?.id else { 
            print("🔍 [DEBUG] isUserInFamilyAsync: Pas d'utilisateur connecté")
            return false 
        }
        
        print("🔍 [DEBUG] isUserInFamilyAsync: Vérification pour userId: \(userId)")
        
        do {
            let user = try await userDatabaseService.getUser(userId: userId)
            print("🔍 [DEBUG] isUserInFamilyAsync: Utilisateur récupéré: \(user?.id ?? "nil")")
            print("🔍 [DEBUG] isUserInFamilyAsync: familyId: \(user?.familyId ?? "nil")")
            
            // Vérifier si familyId existe et n'est pas vide
            if let familyId = user?.familyId {
                let trimmedFamilyId = familyId.trimmingCharacters(in: .whitespacesAndNewlines)
                let isEmpty = trimmedFamilyId.isEmpty
                print("🔍 [DEBUG] isUserInFamilyAsync: familyId après trim: '\(trimmedFamilyId)'")
                print("🔍 [DEBUG] isUserInFamilyAsync: isEmpty: \(isEmpty)")
                return !isEmpty
            }
            print("🔍 [DEBUG] isUserInFamilyAsync: familyId est nil")
            return false
        } catch {
            print("🔍 [DEBUG] isUserInFamilyAsync: Erreur lors de la vérification: \(error)")
            return false
        }
    }
    
    /// Vérifie si l'utilisateur a déjà saisi son nom et sa date de naissance
    func hasUserProfile() -> Bool {
        // Ne plus se fier uniquement à UserDefaults
        // Vérifier que les données sont présentes ET valides
        let savedName = userDefaults.string(forKey: userNameKey) ?? ""
        let savedBirthday = userDefaults.object(forKey: userBirthdayKey) as? Date
        
        print("🔍 [DEBUG] hasUserProfile - savedName: '\(savedName)'")
        print("🔍 [DEBUG] hasUserProfile - savedBirthday: \(String(describing: savedBirthday))")
        
        // Pour qu'un profil soit considéré comme configuré, il faut :
        // 1. Un nom non vide qui n'est pas le nom par défaut "Utilisateur" d'Apple Sign In
        // 2. Une date de naissance
        let hasValidName = !savedName.isEmpty && savedName != "Utilisateur"
        let hasBirthday = savedBirthday != nil
        
        print("🔍 [DEBUG] hasUserProfile - hasValidName: \(hasValidName)")
        print("🔍 [DEBUG] hasUserProfile - hasBirthday: \(hasBirthday)")
        print("🔍 [DEBUG] hasUserProfile - result: \(hasValidName && hasBirthday)")
        
        return hasValidName && hasBirthday
    }
    
    /// Vérifie et passe automatiquement les étapes si nécessaire
    func checkAndSkipSteps() {
        // Si l'utilisateur est déjà dans une famille, passer l'étape 2
        if currentOnboardingStep == 2 && isUserInFamily() {
            currentOnboardingStep = 3
        }
        
        // Si l'utilisateur a déjà un profil, passer l'étape 3
        if currentOnboardingStep == 3 && hasUserProfile() {
            currentOnboardingStep = 4
        }
    }
    
    /// Vérifie et passe automatiquement les étapes si nécessaire (version asynchrone)
    func checkAndSkipStepsAsync() async {
        print("🔍 [DEBUG] checkAndSkipStepsAsync: Début de la vérification")
        print("🔍 [DEBUG] checkAndSkipStepsAsync: currentOnboardingStep: \(currentOnboardingStep)")
        
        // Charger les données de famille d'abord
        await loadFamilyData()
        
        // Vérifier si l'utilisateur est dans une famille
        let isInFamily = await isUserInFamilyAsync()
        print("🔍 [DEBUG] checkAndSkipStepsAsync: isInFamily: \(isInFamily)")
        
        // Si l'utilisateur est déjà dans une famille, passer l'étape 2
        if currentOnboardingStep == 2 && isInFamily {
            print("🔍 [DEBUG] checkAndSkipStepsAsync: Passage de l'étape 2 à 3")
            currentOnboardingStep = 3
        }
        
        // Si l'utilisateur a déjà un profil, passer l'étape 3
        if currentOnboardingStep == 3 && hasUserProfile() {
            print("🔍 [DEBUG] checkAndSkipStepsAsync: Passage de l'étape 3 à 4")
            currentOnboardingStep = 4
        }
        
        print("🔍 [DEBUG] checkAndSkipStepsAsync: Fin de la vérification, currentOnboardingStep: \(currentOnboardingStep)")
    }
    
    /// Initialise les données utilisateur depuis UserDefaults
    func loadUserData() {
        let savedName = userDefaults.string(forKey: userNameKey) ?? ""
        let savedBirthday = userDefaults.object(forKey: userBirthdayKey) as? Date
        
        print("🔍 [DEBUG] loadUserData - savedName: '\(savedName)'")
        print("🔍 [DEBUG] loadUserData - savedBirthday: \(String(describing: savedBirthday))")
        
        // Ne charger les données que si elles sont valides (pas de nom "Utilisateur" par défaut)
        if savedName != "Utilisateur" && !savedName.isEmpty {
            userName = savedName
            print("🔍 [DEBUG] loadUserData - Nom chargé: '\(userName)'")
        } else {
            userName = ""
            print("🔍 [DEBUG] loadUserData - Nom ignoré car invalide")
        }
        
        if let birthday = savedBirthday {
            userBirthday = birthday
            print("🔍 [DEBUG] loadUserData - Date de naissance chargée")
        } else {
            print("🔍 [DEBUG] loadUserData - Aucune date de naissance trouvée")
        }
    }
    
    /// Charge les données de famille depuis la base de données
    func loadFamilyData() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        do {
            let user = try await userDatabaseService.getUser(userId: userId)
            if let user = user, let familyId = user.familyId {
                // Récupérer les informations de la famille
                let family = try await familyDatabaseService.getFamily(familyId: familyId)
                await MainActor.run {
                    currentFamily = family
                }
            }
        } catch {
            print("Erreur lors du chargement des données de famille: \(error)")
        }
    }
    
    /// Nettoie les données UserDefaults lors de la déconnexion
    func clearUserData() {
        print("🧹 [DEBUG] Nettoyage des données UserDefaults...")
        print("🧹 [DEBUG] Avant nettoyage - userName: '\(userDefaults.string(forKey: userNameKey) ?? "nil")'")
        print("🧹 [DEBUG] Avant nettoyage - userBirthday: \(userDefaults.object(forKey: userBirthdayKey) ?? "nil")")
        
        userDefaults.removeObject(forKey: hasSeenOnboardingKey)
        userDefaults.removeObject(forKey: userNameKey)
        userDefaults.removeObject(forKey: userBirthdayKey)
        
        // Force la synchronisation
        userDefaults.synchronize()
        
        print("🧹 [DEBUG] Après nettoyage - userName: '\(userDefaults.string(forKey: userNameKey) ?? "nil")'")
        print("🧹 [DEBUG] Après nettoyage - userBirthday: \(userDefaults.object(forKey: userBirthdayKey) ?? "nil")")
        
        // Réinitialiser les variables d'instance
        userName = ""
        userBirthday = Date()
        currentOnboardingStep = 1
        currentFamily = nil
        shouldShowOnboarding = false
        isAuthenticated = false
    }
    
    /// Force le nettoyage des données (pour débogage)
    func forceResetOnboarding() {
        print("🔄 [DEBUG] Force reset de l'onboarding...")
        clearUserData()
        currentOnboardingStep = 1
        print("🔄 [DEBUG] Reset terminé, hasUserProfile: \(hasUserProfile())")
    }
    
    /// Initialise l'onboarding avec vérification automatique des étapes
    func initializeOnboarding() async {
        print("🔍 [DEBUG] initializeOnboarding: Début de l'initialisation")
        
        // Charger les données utilisateur
        loadUserData()
        
        // Charger les données de famille et vérifier les étapes
        await checkAndSkipStepsAsync()
        
        print("🔍 [DEBUG] initializeOnboarding: Fin de l'initialisation, currentOnboardingStep: \(currentOnboardingStep)")
    }
}
