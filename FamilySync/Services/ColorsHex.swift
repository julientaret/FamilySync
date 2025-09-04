//
//  ColorsHex.swift
//  FamilySync
//
//  Created by Julien TARET on 04/09/2025.
//

import SwiftUI

// MARK: - Extension pour SwiftUI Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Extension pour UIKit UIColor
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - Exemples d'utilisation

// Exemple 1: SwiftUI avec ta couleur #e9906f
struct HexBackgroundView: View {
    var body: some View {
        ZStack {
            // Background avec couleur hex
            Color(hex: "#e9906f")
                .ignoresSafeArea()
            
            Text("Hello World")
                .foregroundColor(.white)
                .font(.largeTitle)
        }
    }
}

// Exemple 2: Gradient avec des couleurs hex
struct HexGradientView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#e9906f"),    // Ta couleur
                Color(hex: "#f4b183"),    // Plus clair
                Color(hex: "#f8d7da")     // Rose pâle
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

// Exemple 3: Définir des couleurs personnalisées avec hex
extension Color {
    static let customOrange = Color(hex: "#e9906f")
    static let customPeach = Color(hex: "#f4b183")
    static let customPink = Color(hex: "#f8d7da")
}

// Utilisation simple
struct SimpleUsageView: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.customOrange)
                .frame(height: 100)
            
            Rectangle()
                .fill(Color(hex: "e9906f")) // Sans # aussi ça marche
                .frame(height: 100)
        }
    }
}

// MARK: - Pour UIKit (View Controllers)
class HexColorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background avec couleur hex
        view.backgroundColor = UIColor(hex: "#e9906f")
        
        // Ou pour un gradient en UIKit
        setupHexGradient()
    }
    
    private func setupHexGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        gradientLayer.colors = [
            UIColor(hex: "#e9906f").cgColor,
            UIColor(hex: "#f4b183").cgColor,
            UIColor(hex: "#f8d7da").cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
