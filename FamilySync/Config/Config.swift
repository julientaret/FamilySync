import Foundation
import CryptoKit

/// Configuration sécurisée pour Appwrite
/// Utilise l'obfuscation pour masquer les valeurs sensibles
struct AppwriteConfig {
    
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
    
    // MARK: - Configuration Obfusquée
    // Les valeurs sont encodées en base64 et XORées avec une clé
    private static let obfuscatedProjectId = "kOC+c/dJxYK+OlLRUJ4SaWm5OKY="
    private static let obfuscatedProjectName = "4LmxLPkC8J/gaQ=="
    private static let obfuscatedEndpoint = "zqyoNeZBjMnoeALNBMYcKDjxbe5lBCWBgMXxewsNZ+s="
    
    // Clé de désobfuscation (peut être stockée dans Keychain en production)
    private static let obfuscationKey = "FamilySync2024"
    
    // MARK: - Propriétés Publiques
    static var projectId: String {
        return deobfuscate(obfuscatedProjectId, key: obfuscationKey)
    }
    
    static var projectName: String {
        return deobfuscate(obfuscatedProjectName, key: obfuscationKey)
    }
    
    static var endpoint: String {
        return deobfuscate(obfuscatedEndpoint, key: obfuscationKey)
    }
}