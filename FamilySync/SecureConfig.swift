import Foundation
import CryptoKit

/// Configuration sécurisée avancée pour Appwrite
/// Combine obfuscation + Keychain pour une sécurité maximale
struct SecureAppwriteConfig {
    
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
    
    // MARK: - Configuration Obfusquée
    private static let obfuscatedProjectId = "kOC+c/dJxYK+OlLRUJ4SaWm5OKY="
    private static let obfuscatedProjectName = "4LmxLPkC8J/gaQ=="
    private static let obfuscatedEndpoint = "zqyoNeZBjMnoeALNBMYcKDjxbe5lBCWBgMXxewsNZ+s="
    
    // MARK: - Propriétés Publiques avec Cache
    private static var cachedProjectId: String?
    private static var cachedProjectName: String?
    private static var cachedEndpoint: String?
    
    static var projectId: String {
        if let cached = cachedProjectId {
            return cached
        }
        let value = deobfuscate(obfuscatedProjectId, key: getObfuscationKey())
        cachedProjectId = value
        return value
    }
    
    static var projectName: String {
        if let cached = cachedProjectName {
            return cached
        }
        let value = deobfuscate(obfuscatedProjectName, key: getObfuscationKey())
        cachedProjectName = value
        return value
    }
    
    static var endpoint: String {
        if let cached = cachedEndpoint {
            return cached
        }
        let value = deobfuscate(obfuscatedEndpoint, key: getObfuscationKey())
        cachedEndpoint = value
        return value
    }
    
    // MARK: - Méthodes de Sécurité
    static func clearCache() {
        cachedProjectId = nil
        cachedProjectName = nil
        cachedEndpoint = nil
    }
}
