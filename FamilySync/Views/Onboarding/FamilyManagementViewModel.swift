import Foundation
import SwiftUI

/// ViewModel pour gérer la logique métier des familles
@MainActor
class FamilyManagementViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // États pour les modals
    @Published var showCreateFamilyModal: Bool = false
    @Published var showJoinFamilyModal: Bool = false
    @Published var showInviteCodeModal: Bool = false
    
    // Données des modals
    @Published var familyName: String = ""
    @Published var inviteCode: String = ""
    @Published var generatedInviteCode: String = ""
    
    // Famille créée/rejointe
    @Published var currentFamily: Family?
    
    private let familyService = FamilyDatabaseService.shared
    private let userService = UserDatabaseService.shared
    
    /// Valide le nom de la famille
    func validateFamilyName() -> Bool {
        let trimmedName = familyName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.count >= 2 && trimmedName.count <= 50
    }
    
    /// Valide le code d'invitation
    func validateInviteCode() -> Bool {
        let trimmedCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedCode.count == 8 && trimmedCode.allSatisfy { $0.isLetter || $0.isNumber }
    }
    
    /// Crée une nouvelle famille
    func createFamily(userId: String) async {
        guard validateFamilyName() else {
            errorMessage = "Le nom de la famille doit contenir entre 2 et 50 caractères"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let family = try await familyService.createFamily(
                name: familyName.trimmingCharacters(in: .whitespacesAndNewlines),
                creatorId: userId
            )
            
            // Mettre à jour l'utilisateur avec la famille
            _ = try await userService.updateUserFamily(userId: userId, familyId: family.id)
            
            currentFamily = family
            generatedInviteCode = family.inviteCode
            showCreateFamilyModal = false
            showInviteCodeModal = true
            
        } catch {
            errorMessage = "Erreur lors de la création de la famille: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    /// Rejoint une famille existante
    func joinFamily(userId: String) async {
        guard validateInviteCode() else {
            errorMessage = "Le code d'invitation doit contenir exactement 8 caractères (lettres et chiffres)"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let family = try await familyService.joinFamily(
                inviteCode: inviteCode.trimmingCharacters(in: .whitespacesAndNewlines),
                userId: userId
            )
            
            // Mettre à jour l'utilisateur avec la famille
            _ = try await userService.updateUserFamily(userId: userId, familyId: family.id)
            
            currentFamily = family
            showJoinFamilyModal = false
            
        } catch FamilyError.invalidInviteCode {
            errorMessage = "Code d'invitation invalide"
            showError = true
        } catch FamilyError.alreadyMember {
            errorMessage = "Vous êtes déjà membre de cette famille"
            showError = true
        } catch {
            errorMessage = "Erreur lors de la jointure de la famille: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    /// Réinitialise les données des modals
    func resetModalData() {
        familyName = ""
        inviteCode = ""
        generatedInviteCode = ""
        errorMessage = nil
        showError = false
    }
    
    /// Ferme toutes les modals
    func closeAllModals() {
        showCreateFamilyModal = false
        showJoinFamilyModal = false
        showInviteCodeModal = false
        resetModalData()
    }
}
