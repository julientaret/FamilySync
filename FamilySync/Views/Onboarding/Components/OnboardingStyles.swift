//
//  OnboardingStyles.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

// MARK: - Colors
struct OnboardingColors {
    static let primary = Color(red: 1.0, green: 0.6, blue: 0.5)
    static let secondary = Color(red: 0.4, green: 0.8, blue: 0.8)
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.7, blue: 0.6),    // Couleur coral/saumon en haut
            Color(red: 1.0, green: 0.85, blue: 0.7),   // Couleur pêche au milieu
            Color(red: 0.98, green: 0.75, blue: 0.80)  // Couleur rose pâle en bas
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Text Styles
struct OnboardingTextStyles {
    static func title(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(OnboardingColors.primary)
    }
    
    static func largeTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 35, weight: .black, design: .rounded))
            .foregroundColor(OnboardingColors.primary)
    }
    
    static func description(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(OnboardingColors.primary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
    }
    
    static func separator(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(OnboardingColors.primary)
    }
}

// MARK: - Button Styles
struct OnboardingButtonStyles {
    static func primaryButton(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(OnboardingColors.primary)
                .cornerRadius(10)
        }
        .padding(.horizontal, 40)
    }
    
    static func secondaryButton(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(OnboardingColors.secondary)
                .cornerRadius(10)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Background Component
struct OnboardingBackground: View {
    var body: some View {
        OnboardingColors.backgroundGradient
            .opacity(0.2)
            .ignoresSafeArea()
    }
}

// MARK: - Title Component
struct OnboardingTitle: View {
    let firstLine: String
    let secondLine: String
    
    var body: some View {
        VStack(spacing: 8) {
            OnboardingTextStyles.title(firstLine)
            OnboardingTextStyles.largeTitle(secondLine)
        }
        .shadow(color: Color.white.opacity(0.4), radius: 3, x: 0, y: 2)
        .padding(.top, 40)
    }
}
