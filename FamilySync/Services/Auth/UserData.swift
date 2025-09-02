import Foundation
import AppwriteModels
import JSONCodable

/// Alias pour le type User d'Appwrite avec AnyCodable
typealias AppwriteUser = User<[String: AnyCodable]>
