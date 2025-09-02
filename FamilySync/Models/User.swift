import Foundation

struct FamilySyncUser: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let createdAt: String
    let familyId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case email
        case name
        case createdAt = "$createdAt"
        case familyId
    }
}