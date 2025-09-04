import Foundation
import Appwrite
import AppwriteEnums
import AuthenticationServices
import CryptoKit

/// Erreurs spécifiques à Apple Sign In (RGPD compliant)
enum AppleSignInError: Error, LocalizedError {
    case authenticationFailed
    case userCancelled
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Échec de l'authentification"
        case .userCancelled:
            return "Authentification annulée"
        case .networkError:
            return "Erreur de connexion réseau"
        }
    }
}

/// Service pour Apple Sign In avec OAuth2 Appwrite
class AppleSignInService: ObservableObject {
    static let shared = AppleSignInService()
    
    private let client: Client
    private let account: Account
    private let userDatabaseService = UserDatabaseService.shared
    
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
    
    /// Connexion avec Apple Sign In (RGPD compliant - aucune donnée personnelle collectée)
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            print("🍎 Connexion Apple RGPD compliant (aucune donnée personnelle collectée)...")
            
            // Utiliser uniquement l'Apple User ID (anonymisé)
            let appleUserId = credential.user
            print("🔐 Authentification avec Apple User ID anonymisé")
            
            // Créer un ID utilisateur stable et anonymisé
            let stableUserId = generateStableUserId(from: appleUserId)
            let password = generateSecurePassword(from: appleUserId)
            
            // Email anonymisé pour Appwrite (pas de vraie donnée personnelle)
            let anonymousEmail = "\(stableUserId)@familysync.anonymous"
            
            // Nom anonymisé pour Appwrite (pas de vraie donnée personnelle)
            let anonymousName = "Utilisateur"
            
            // Essayer de se connecter avec un utilisateur existant
            do {
                _ = try await account.createEmailPasswordSession(
                    email: anonymousEmail,
                    password: password
                )
                print("✅ Connexion réussie avec utilisateur existant")
                
            } catch {
                print("ℹ️ Utilisateur n'existe pas, création...")
                
                // Créer un nouveau compte avec des données anonymisées
                do {
                    _ = try await account.create(
                        userId: stableUserId,
                        email: anonymousEmail,
                        password: password,
                        name: anonymousName
                    )
                    
                    // Puis se connecter
                    _ = try await account.createEmailPasswordSession(
                        email: anonymousEmail,
                        password: password
                    )
                    print("✅ Nouveau compte créé et connecté (RGPD compliant)")
                    
                } catch {
                    print("❌ Erreur lors de la création: \(error)")
                    throw AppleSignInError.authenticationFailed
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
    
    /// Génère un mot de passe sécurisé (RGPD compliant)
    private func generateSecurePassword(from appleUserId: String) -> String {
        // Créer un hash SHA256 avec un salt pour plus de sécurité
        let salt = "FamilySync_RGDP_Salt_2024"
        let inputData = Data("\(appleUserId)\(salt)".utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        
        // Prendre les premiers 32 caractères pour un mot de passe fort
        return String(hashString.prefix(32))
    }
    
    /// Valide un email selon les standards RFC (RGPD compliant - validation technique uniquement)
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
            
            // Enregistrer l'utilisateur dans la base de données
            _ = try await userDatabaseService.ensureUserExists(userId: user.id)
            
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