import Foundation

/// Modèle représentant une famille dans l'application
struct Family: Codable, Equatable {
    let id: String
    let familiesId: String
    let name: String
    let creatorId: String
    let members: [String]
    let inviteCode: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case familiesId = "families_id"
        case name
        case creatorId = "creator_id"
        case members
        case inviteCode = "invite_code"
        case createdAt = "$createdAt"
        case updatedAt = "$updatedAt"
    }
    
    /// Initialise une famille avec les données de base
    init(id: String, familiesId: String, name: String, creatorId: String, members: [String], inviteCode: String, createdAt: String, updatedAt: String) {
        self.id = id
        self.familiesId = familiesId
        self.name = name
        self.creatorId = creatorId
        self.members = members
        self.inviteCode = inviteCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Crée une nouvelle famille avec les données minimales
    static func create(name: String, creatorId: String, inviteCode: String) -> [String: Any] {
        // Générer un ID unique de 32 caractères maximum
        let uniqueId = String(UUID().uuidString.prefix(32))
        
        // Tronquer l'ID du créateur à 32 caractères maximum
        let truncatedCreatorId = String(creatorId.prefix(32))
        
        return [
            "families_id": uniqueId,
            "name": name,
            "creator_id": truncatedCreatorId,
            "members": [truncatedCreatorId], // Utiliser l'ID tronqué
            "invite_code": inviteCode
        ]
    }
}
