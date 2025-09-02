import Foundation

/// Configuration pour les URLs de callback OAuth2
struct OAuth2Config {
    // URLs de callback pour chaque provider
    static let appleCallbackURL = "https://fra.cloud.appwrite.io/v1/account/sessions/oauth2/callback/apple/68b6b2fd001274a45f48"
    static let githubCallbackURL = "https://fra.cloud.appwrite.io/v1/account/sessions/oauth2/callback/github/68b6b2fd001274a45f48"
    static let googleCallbackURL = "https://fra.cloud.appwrite.io/v1/account/sessions/oauth2/callback/google/68b6b2fd001274a45f48"
    
    // URLs de succès et d'échec (optionnel)
    static let successURL = "https://familysync.app/success"
    static let failureURL = "https://familysync.app/failure"
    
    // Scopes par défaut pour chaque provider
    static let appleScopes = ["name", "email"]
    static let githubScopes = ["user", "repo"]
    static let googleScopes = ["profile", "email"]
    
    /// Retourne l'URL de callback pour un provider donné
    /// - Parameter provider: Le provider OAuth2
    /// - Returns: L'URL de callback correspondante
    static func getCallbackURL(for provider: String) -> String {
        switch provider.lowercased() {
        case "apple":
            return appleCallbackURL
        case "github":
            return githubCallbackURL
        case "google":
            return googleCallbackURL
        default:
            return ""
        }
    }
    
    /// Retourne les scopes par défaut pour un provider donné
    /// - Parameter provider: Le provider OAuth2
    /// - Returns: Les scopes par défaut
    static func getDefaultScopes(for provider: String) -> [String] {
        switch provider.lowercased() {
        case "apple":
            return appleScopes
        case "github":
            return githubScopes
        case "google":
            return googleScopes
        default:
            return []
        }
    }
}
