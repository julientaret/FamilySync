//
//  OnboardingStep.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct OnboardingStep: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkmark Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray.opacity(0.4))
                .frame(width: 24, height: 24)
            
            // Step Text
            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.5))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingStep(
            icon: "checkmark.circle.fill",
            text: "Log in with your Apple Account"
        )
        
        OnboardingStep(
            icon: "checkmark.circle.fill",
            text: "Create or join a Family"
        )
        
        OnboardingStep(
            icon: "checkmark.circle.fill",
            text: "Set your profile"
        )
    }
    .padding()
    .background(Color(red: 0.98, green: 0.95, blue: 0.92))
}
