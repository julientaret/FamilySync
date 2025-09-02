import Foundation
import Security

/// Service pour gérer le stockage sécurisé dans le Keychain
/// Permet de stocker et récupérer des données sensibles de manière cryptée
@MainActor
class KeychainService {
    
    // MARK: - Types
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
        case invalidItemFormat
        case encodingError
    }
    
    // MARK: - Configuration
    private static let serviceName = "com.familysync.app"
    
    // MARK: - Méthodes Publiques
    
    /// Sauvegarde une valeur dans le Keychain
    /// - Parameters:
    ///   - value: La valeur à sauvegarder
    ///   - key: La clé d'identification
    /// - Throws: KeychainError en cas d'erreur
    static func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // L'élément existe déjà, on le met à jour
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unknown(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    /// Récupère une valeur depuis le Keychain
    /// - Parameter key: La clé d'identification
    /// - Returns: La valeur stockée ou nil si non trouvée
    /// - Throws: KeychainError en cas d'erreur
    static func retrieve(for key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unknown(status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        return string
    }
    
    /// Supprime une valeur du Keychain
    /// - Parameter key: La clé d'identification
    /// - Throws: KeychainError en cas d'erreur
    static func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
    
    /// Vérifie si une clé existe dans le Keychain
    /// - Parameter key: La clé d'identification
    /// - Returns: true si la clé existe
    static func exists(for key: String) -> Bool {
        do {
            return try retrieve(for: key) != nil
        } catch {
            return false
        }
    }
}

// MARK: - Extensions Utilitaires
extension KeychainService {
    
    /// Clés prédéfinies pour les configurations sensibles
    enum ConfigKeys {
        static let obfuscationKey = "obfuscation_key"
        static let apiKey = "api_key"
        static let secretKey = "secret_key"
    }
    
    /// Initialise les clés par défaut si elles n'existent pas
    static func initializeDefaultKeys() {
        Task {
            if !exists(for: ConfigKeys.obfuscationKey) {
                try? save("FamilySync2024", for: ConfigKeys.obfuscationKey)
            }
        }
    }
}
