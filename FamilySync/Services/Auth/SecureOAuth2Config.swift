import Foundation
import CryptoKit

/// Configuration sécurisée pour les URLs de callback OAuth2
/// Utilise l'obfuscation pour masquer les URLs sensibles
struct SecureOAuth2Config {
    
    // MARK: - Obfuscation Helpers
    private static func deobfuscate(_ obfuscated: String, key: String) -> String {
        guard let data = Data(base64Encoded: obfuscated),
              let keyData = key.data(using: .utf8) else {
            return ""
        }
        
        let hash = SHA256.hash(data: keyData)
        let keyBytes = Array(hash.prefix(32))
        
        var result = Data()
        for (index, byte) in data.enumerated() {
            let keyByte = keyBytes[index % keyBytes.count]
            let decryptedByte = byte ^ keyByte
            result.append(decryptedByte)
        }
        
        return String(data: result, encoding: .utf8) ?? ""
    }
    
    private static func getObfuscationKey() -> String {
        // Utilise une clé par défaut pour éviter les problèmes d'actor isolation
        return "FamilySync2024"
    }
    
    // MARK: - URLs Obfusquées
    private static let obfuscatedAppleCallbackURL = "aHR0cHM6Ly9mcmEuY2xvdWQuYXBwd3JpdGUuaW8vdjEvYWNjb3VudC9zZXNzaW9ucy9vYXV0aDIvY2FsbGJhY2svYXBwbGUvNjhiNmIyZmQwMDEyNzRhNDVmNDg="
    private static let obfuscatedGithubCallbackURL = "aHR0cHM6Ly9mcmEuY2xvdWQuYXBwd3JpdGUuaW8vdjEvYWNjb3VudC9zZXNzaW9ucy9vYXV0aDIvY2FsbGJhY2svZ2l0aHViLzY4YjZiMmZkMDAxMjc0YTQ1ZjQ4"
    private static let obfuscatedGoogleCallbackURL = "aHR0cHM6Ly9mcmEuY2xvdWQuYXBwd3JpdGUuaW8vdjEvYWNjb3VudC9zZXNzaW9ucy9vYXV0aDIvY2FsbGJhY2svZ29vZ2xlLzY4YjZiMmZkMDAxMjc0YTQ1ZjQ4"
    
    // MARK: - Propriétés Publiques
    static var appleCallbackURL: String {
        return deobfuscate(obfuscatedAppleCallbackURL, key: getObfuscationKey())
    }
    
    static var githubCallbackURL: String {
        return deobfuscate(obfuscatedGithubCallbackURL, key: getObfuscationKey())
    }
    
    static var googleCallbackURL: String {
        return deobfuscate(obfuscatedGoogleCallbackURL, key: getObfuscationKey())
    }
    
    // URLs de succès et d'échec temporaires (pour test)
    static let successURL = "https://httpbin.org/get?status=success"
    static let failureURL = "https://httpbin.org/get?status=failure"
    
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
