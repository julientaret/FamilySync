import Foundation
import Appwrite
import AppwriteEnums

/// Service spécialisé pour Apple Sign In avec Appwrite
class AppleSignInService: ObservableObject {
    static let shared = AppleSignInService()
    
    private let client: Client
    private let account: Account
    
    // URL de callback spécifique pour Apple
    private let appleCallbackURL = "https://fra.cloud.appwrite.io/v1/account/sessions/oauth2/callback/apple/68b6b2fd001274a45f48"
    
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
    
    // MARK: - Apple Sign In
    
    /// Initialise la connexion avec Apple Sign In
    /// - Parameter scopes: Les scopes demandés (nom, email par défaut)
    func signInWithApple(scopes: [String] = ["name", "email"]) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Créer la session OAuth2 avec Apple
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
    
    /// Vérifie si l'utilisateur est connecté avec Apple
    func checkAppleSession() async throws {
        do {
            let session = try await account.getSession(sessionId: "current")
            
            // Vérifier si c'est une session Apple
            if session.provider == "apple" {
                await MainActor.run {
                    isAuthenticated = true
                }
                try await fetchCurrentUser()
            } else {
                await MainActor.run {
                    isAuthenticated = false
                    currentUser = nil
                }
            }
        } catch {
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    // MARK: - User Management
    
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
    
    /// Déconnecte l'utilisateur Apple
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
    
    // MARK: - Apple Specific Features
    
    /// Récupère les informations de session Apple
    func getAppleSessionInfo() async throws -> Session? {
        do {
            let session = try await account.getSession(sessionId: "current")
            if session.provider == "apple" {
                return session
            }
            return nil
        } catch {
            return nil
        }
    }
    
    /// Rafraîchit la session Apple si nécessaire
    func refreshAppleSession() async throws {
        do {
            let session = try await account.getSession(sessionId: "current")
            
            if session.provider == "apple" {
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
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erreur lors du rafraîchissement de la session Apple: \(error.localizedDescription)"
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
        try? await checkAppleSession()
    }
    
    /// Vérifie si Apple Sign In est disponible
    func isAppleSignInAvailable() -> Bool {
        // Vérifier si l'appareil supporte Apple Sign In
        if #available(iOS 13.0, *) {
            return true
        }
        return false
    }
}
