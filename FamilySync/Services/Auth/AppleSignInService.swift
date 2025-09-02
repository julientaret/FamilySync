import Foundation
import Appwrite
import AppwriteEnums
import AuthenticationServices
import CryptoKit

/// Service pour Apple Sign In avec OAuth2 Appwrite
class AppleSignInService: ObservableObject {
    static let shared = AppleSignInService()
    
    private let client: Client
    private let account: Account
    
    @Published var isAuthenticated = false
    @Published var currentUser: AppwriteUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        client = Client()
            .setEndpoint(AppwriteConfig.endpoint)
            .setProject(AppwriteConfig.projectId)
        
        account = Account(client)
    }
    
    // MARK: - Apple Sign In OAuth2
    
    /// Connexion avec Apple Sign In utilisant les credentials natifs
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            print("🍎 Connexion Apple avec credentials natifs...")
            
            // Extraire les informations du credential Apple
            let appleUserId = credential.user
            let email = credential.email ?? "\(appleUserId)@privaterelay.appleid.com"
            
            // Construire le nom complet avec validation
            let fullName: String
            if let appleFullName = credential.fullName {
                let firstName = appleFullName.givenName ?? ""
                let lastName = appleFullName.familyName ?? ""
                let constructedName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
                
                // S'assurer que le nom n'est pas vide et respecte les limites
                if !constructedName.isEmpty && constructedName.count <= 128 {
                    fullName = constructedName
                } else {
                    fullName = "Utilisateur Apple"
                }
            } else {
                fullName = "Utilisateur Apple"
            }
            
            print("🔐 Tentative de connexion pour: \(email)")
            
            // Créer un ID utilisateur stable et conforme aux règles Appwrite
            let stableUserId = generateStableUserId(from: appleUserId)
            let password = "apple_\(stableUserId)_pwd"
            
            // Essayer de se connecter avec un utilisateur existant
            do {
                _ = try await account.createEmailPasswordSession(
                    email: email,
                    password: password
                )
                print("✅ Connexion réussie avec utilisateur existant")
                
            } catch {
                print("ℹ️ Utilisateur n'existe pas, création...")
                
                // Si la connexion échoue, créer un nouveau compte
                do {
                    _ = try await account.create(
                        userId: stableUserId,
                        email: email,
                        password: password,
                        name: fullName
                    )
                    
                    // Puis se connecter
                    _ = try await account.createEmailPasswordSession(
                        email: email,
                        password: password
                    )
                    print("✅ Nouveau compte créé et connecté")
                    
                } catch {
                    print("❌ Erreur lors de la création: \(error)")
                    throw error
                }
            }
            
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
            }
            
            // Récupérer les informations utilisateur
            try await fetchCurrentUser()
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Utilitaires
    
    /// Génère un userId stable et conforme aux règles Appwrite à partir de l'Apple User ID
    private func generateStableUserId(from appleUserId: String) -> String {
        // Créer un hash SHA256 de l'Apple User ID
        let inputData = Data(appleUserId.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        
        // Prendre les premiers 30 caractères pour rester sous la limite de 36
        // Préfixer avec "apple_" (6 chars) pour un total de 36 chars max
        let shortHash = String(hashString.prefix(30))
        return "apple_\(shortHash)"
    }
    
    // MARK: - Gestion des sessions
    
    /// Récupère les informations de l'utilisateur connecté
    func fetchCurrentUser() async throws {
        do {
            let user = try await account.get()
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
            throw error
        }
    }
    
    /// Déconnexion de l'utilisateur
    func signOut() async throws {
        do {
            _ = try await account.deleteSession(sessionId: "current")
            
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
}