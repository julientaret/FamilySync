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
    let isCompleted: Bool
    
    init(icon: String, text: String, isCompleted: Bool = false) {
        self.icon = icon
        self.text = text
        self.isCompleted = isCompleted
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Step Icon - Circle empty when not completed, checkmark when completed
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isCompleted ? .green : OnboardingColors.primary)
                .frame(width: 24, height: 24)
            
            // Step Text
            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(OnboardingColors.primary)
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
            text: "Log in with your Apple Account",
            isCompleted: true
        )
        
        OnboardingStep(
            icon: "checkmark.circle.fill",
            text: "Create or join a Family",
            isCompleted: false
        )
        
        OnboardingStep(
            icon: "checkmark.circle.fill",
            text: "Set your profile",
            isCompleted: false
        )
    }
    .padding()
    .background(Color(red: 0.98, green: 0.95, blue: 0.92))
}
