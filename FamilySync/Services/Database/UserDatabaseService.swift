import Foundation
import Appwrite
import AppwriteEnums

struct UserDocument: Codable {
    let id: String
    let userId: String
    let familyId: String?
    let name: String?
    let birthday: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case userId = "user_id"
        case familyId = "family_id"
        case name = "name"
        case birthday = "birthday"
        case createdAt = "$createdAt"
        case updatedAt = "$updatedAt"
    }
}

class UserDatabaseService: ObservableObject {
    static let shared = UserDatabaseService()
    
    private let client: Client
    private let databases: Databases
    
    private let databaseId = "68b71f3800292dc2e621"
    private let collectionId = "users"
    
    private init() {
        client = Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId)
        
        databases = Databases(client)
    }
    
    /// Enregistre un utilisateur dans la base de données
    func createUser(userId: String) async throws -> UserDocument {
        do {
            let document = try await databases.createDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: userId, // Utilise le même ID que l'auth
                data: [
                    "user_id": userId
                ]
            )
            
            return UserDocument(
                id: document.id,
                userId: userId,
                familyId: nil,
                name: nil,
                birthday: nil,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            throw error
        }
    }
    
    /// Récupère un utilisateur depuis la base de données
    func getUser(userId: String) async throws -> UserDocument? {
        do {
            let document = try await databases.getDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: userId
            )
            
            return UserDocument(
                id: document.id,
                userId: document.data["user_id"]?.value as? String ?? "",
                familyId: document.data["family_id"]?.value as? String,
                name: document.data["name"]?.value as? String,
                birthday: document.data["birthday"]?.value as? String,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            // Si l'utilisateur n'existe pas, retourne nil
            return nil
        }
    }
    
    /// Met à jour un utilisateur dans la base de données
    func updateUser(userId: String, data: [String: Any]) async throws -> UserDocument {
        do {
            let document = try await databases.updateDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: userId,
                data: data
            )
            
            return UserDocument(
                id: document.id,
                userId: document.data["user_id"]?.value as? String ?? "",
                familyId: document.data["family_id"]?.value as? String,
                name: document.data["name"]?.value as? String,
                birthday: document.data["birthday"]?.value as? String,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            throw error
        }
    }
    
    /// Met à jour le profil utilisateur avec le nom et la date de naissance
    func updateUserProfile(userId: String, name: String, birthday: Date) async throws -> UserDocument {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birthdayString = dateFormatter.string(from: birthday)
            
            let document = try await databases.updateDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: userId,
                data: [
                    "name": name,
                    "birthday": birthdayString
                ]
            )
            
            return UserDocument(
                id: document.id,
                userId: document.data["user_id"]?.value as? String ?? "",
                familyId: document.data["family_id"]?.value as? String,
                name: document.data["name"]?.value as? String,
                birthday: document.data["birthday"]?.value as? String,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            throw error
        }
    }
    
    /// Met à jour la famille d'un utilisateur
    func updateUserFamily(userId: String, familyId: String) async throws -> UserDocument {
        do {
            let document = try await databases.updateDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: userId,
                data: [
                    "family_id": familyId
                ]
            )
            
            return UserDocument(
                id: document.id,
                userId: document.data["user_id"]?.value as? String ?? "",
                familyId: document.data["family_id"]?.value as? String,
                name: document.data["name"]?.value as? String,
                birthday: document.data["birthday"]?.value as? String,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt
            )
        } catch {
            throw error
        }
    }
    
    /// Vérifie si un utilisateur existe, sinon le crée
    func ensureUserExists(userId: String) async throws -> UserDocument {
        if let existingUser = try await getUser(userId: userId) {
            return existingUser
        } else {
            return try await createUser(userId: userId)
        }
    }
}