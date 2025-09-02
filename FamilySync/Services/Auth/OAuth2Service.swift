import Foundation
import Appwrite
import AppwriteEnums

/// Service pour gérer l'authentification OAuth2 avec Appwrite
class OAuth2Service: ObservableObject {
    static let shared = OAuth2Service()
    
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
    
    // MARK: - OAuth2 Authentication
    
    /// Initialise une session OAuth2 avec Apple
    /// - Parameter scopes: Les scopes demandés (optionnel)
    func signInWithApple(scopes: [String] = []) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await account.createOAuth2Session(
                provider: .apple,
                scopes: scopes
            )
            
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
            }
            
            // Récupérer les informations de l'utilisateur
            try await fetchCurrentUser()
            
        } catch {
            await MainActor.run {
                errorMessage = "Erreur de connexion Apple: \(error.localizedDescription)"
                isLoading = false
            }
            throw error
        }
    }
    
    /// Initialise une session OAuth2 avec GitHub
    /// - Parameter scopes: Les scopes demandés (optionnel)
    func signInWithGitHub(scopes: [String] = ["user"]) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await account.createOAuth2Session(
                provider: .github,
                scopes: scopes
            )
            
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
            }
            
            // Récupérer les informations de l'utilisateur
            try await fetchCurrentUser()
            
        } catch {
            await MainActor.run {
                errorMessage = "Erreur de connexion GitHub: \(error.localizedDescription)"
                isLoading = false
            }
            throw error
        }
    }
    
    /// Initialise une session OAuth2 avec Google
    /// - Parameter scopes: Les scopes demandés (optionnel)
    func signInWithGoogle(scopes: [String] = ["profile", "email"]) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await account.createOAuth2Session(
                provider: .google,
                scopes: scopes
            )
            
            await MainActor.run {
                isAuthenticated = true
                isLoading = false
            }
            
            // Récupérer les informations de l'utilisateur
            try await fetchCurrentUser()
            
        } catch {
            await MainActor.run {
                errorMessage = "Erreur de connexion Google: \(error.localizedDescription)"
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Session Management
    
    /// Récupère l'utilisateur actuel
    func fetchCurrentUser() async throws {
        do {
            let user = try await account.get()
            await MainActor.run {
                currentUser = user
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur lors de la récupération de l'utilisateur: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Vérifie si une session existe
    func checkSession() async throws {
        do {
            let session = try await account.getSession(sessionId: "current")
            await MainActor.run {
                isAuthenticated = true
            }
            try await fetchCurrentUser()
        } catch {
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    /// Déconnecte l'utilisateur
    func signOut() async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await account.deleteSession(sessionId: "current")
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur lors de la déconnexion: \(error.localizedDescription)"
                isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - OAuth2 Profile Management
    
    /// Récupère les informations de session OAuth2
    func getOAuth2Session() async throws -> Session? {
        do {
            let session = try await account.getSession(sessionId: "current")
            return session
        } catch {
            return nil
        }
    }
    
    /// Rafraîchit la session OAuth2
    func refreshOAuth2Session() async throws {
        do {
            let session = try await account.getSession(sessionId: "current")
            
            // Vérifier si le token est sur le point d'expirer
            if !session.providerAccessTokenExpiry.isEmpty {
                let expiryValue = TimeInterval(session.providerAccessTokenExpiry) ?? 0
                let expiryDate = Date(timeIntervalSince1970: expiryValue)
                let now = Date()
                
                // Si le token expire dans moins de 24h, le rafraîchir
                if expiryDate.timeIntervalSince(now) < 86400 {
                    // Note: updateOAuth2Session n'est pas disponible dans cette version
                    // La session sera automatiquement rafraîchie lors de la prochaine utilisation
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur lors du rafraîchissement de la session: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - Utility Methods
    
    /// Nettoie les messages d'erreur
    func clearError() {
        errorMessage = nil
    }
    
    /// Initialise le service au démarrage de l'app
    func initialize() async {
        try? await checkSession()
    }
}
