import Foundation
import Appwrite
import AppwriteEnums

/// Service pour gérer les opérations de base de données liées aux familles
@MainActor
class FamilyDatabaseService: ObservableObject {
    static let shared = FamilyDatabaseService()
    
    private let client: Client
    private let databases: Databases
    private let account: Account
    
    private let databaseId = "68b71f3800292dc2e621"
    private let collectionId = "families"
    
    private init() {
        client = Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId)
        
        databases = Databases(client)
        account = Account(client)
    }
    
    /// Génère un code d'invitation sécurisé et unique
    private func generateInviteCode() -> String {
        // Utiliser des caractères alphanumériques pour plus de sécurité
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        // Générer un code de 16 caractères pour plus de sécurité
        // 16 caractères = 36^16 combinaisons possibles = ~2.8 x 10^24
        let codeLength = 16
        
        // Générer le code principal
        let mainCode = String((0..<codeLength).map { _ in characters.randomElement()! })
        
        // Ajouter un timestamp pour garantir l'unicité
        let timestamp = Int(Date().timeIntervalSince1970)
        let timestampString = String(timestamp, radix: 36).uppercased()
        
        // Combiner le code principal avec le timestamp (format: CODE-TIMESTAMP)
        return "\(mainCode)-\(timestampString)"
    }
    
    /// Crée une nouvelle famille avec permissions sécurisées
    func createFamily(name: String, creatorId: String) async throws -> Family {
        do {
            let inviteCode = generateInviteCode()
            let familyData = Family.create(name: name, creatorId: creatorId, inviteCode: inviteCode)
            
            let document = try await databases.createDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: "uniqueId()",
                data: familyData
            )
            
            return Family(
                id: document.id,
                familiesId: document.data["families_id"]?.value as? String ?? "",
                name: document.data["name"]?.value as? String ?? "",
                creatorId: document.data["creator_id"]?.value as? String ?? "",
                members: document.data["members"]?.value as? [String] ?? [],
                inviteCode: document.data["invite_code"]?.value as? String ?? "",
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            throw error
        }
    }
    
    /// Rejoint une famille avec un code d'invitation
    func joinFamily(inviteCode: String, userId: String) async throws -> Family {
        do {
            // Rechercher la famille par le code d'invitation
            let families = try await databases.listDocuments(
                databaseId: databaseId,
                collectionId: collectionId,
                queries: [
                    Query.equal("invite_code", value: inviteCode)
                ]
            )
            
            guard let familyDocument = families.documents.first else {
                throw FamilyError.invalidInviteCode
            }
            
            // Vérifier si l'utilisateur n'est pas déjà membre
            let currentMembers = familyDocument.data["members"]?.value as? [String] ?? []
            if currentMembers.contains(userId) {
                throw FamilyError.alreadyMember
            }
            
            // Ajouter l'utilisateur à la famille
            var updatedMembers = currentMembers
            updatedMembers.append(userId)
            
            // Mettre à jour le document sans modifier les permissions existantes
            let updatedDocument = try await databases.updateDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: familyDocument.id,
                data: [
                    "members": updatedMembers
                ]
            )
            
            return Family(
                id: updatedDocument.id,
                familiesId: updatedDocument.data["families_id"]?.value as? String ?? "",
                name: updatedDocument.data["name"]?.value as? String ?? "",
                creatorId: updatedDocument.data["creator_id"]?.value as? String ?? "",
                members: updatedDocument.data["members"]?.value as? [String] ?? [],
                inviteCode: updatedDocument.data["invite_code"]?.value as? String ?? "",
                createdAt: updatedDocument.createdAt,
                updatedAt: updatedDocument.updatedAt
            )
        } catch {
            throw error
        }
    }
    
    /// Récupère une famille par son ID
    func getFamily(familyId: String) async throws -> Family? {
        do {
            let document = try await databases.getDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: familyId
            )
            
            return Family(
                id: document.id,
                familiesId: document.data["families_id"]?.value as? String ?? "",
                name: document.data["name"]?.value as? String ?? "",
                creatorId: document.data["creator_id"]?.value as? String ?? "",
                members: document.data["members"]?.value as? [String] ?? [],
                inviteCode: document.data["invite_code"]?.value as? String ?? "",
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            return nil
        }
    }
    
    /// Met à jour une famille
    func updateFamily(familyId: String, data: [String: Any]) async throws -> Family {
        do {
            let document = try await databases.updateDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: familyId,
                data: data
            )
            
            return Family(
                id: document.id,
                familiesId: document.data["families_id"]?.value as? String ?? "",
                name: document.data["name"]?.value as? String ?? "",
                creatorId: document.data["creator_id"]?.value as? String ?? "",
                members: document.data["members"]?.value as? [String] ?? [],
                inviteCode: document.data["invite_code"]?.value as? String ?? "",
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            throw error
        }
    }
}

/// Erreurs spécifiques aux familles
enum FamilyError: Error, LocalizedError {
    case invalidInviteCode
    case alreadyMember
    case familyNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidInviteCode:
            return "Le code d'invitation n'est pas valide"
        case .alreadyMember:
            return "Vous êtes déjà membre de cette famille"
        case .familyNotFound:
            return "Famille introuvable"
        }
    }
}
