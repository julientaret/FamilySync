//
//  OnboardingView2.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct OnboardingView2: View {
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground()
            
            VStack(spacing: 40) {
                // Title
                OnboardingTitle(firstLine: "Create Your", secondLine: "Family")
                
                // Steps
                VStack(spacing: 20) {
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Log in with your Apple Account",
                        isCompleted: true
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
                
                
                // Family Illustration
                Image("onboard2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding(.horizontal, 40)
                                
                // Action Buttons
                VStack(spacing: 16) {
                    OnboardingButtonStyles.primaryButton("Create Family") {
                        // TODO: Handle create family action
                    }
                    
                    OnboardingTextStyles.separator("Or")
                    
                    OnboardingButtonStyles.secondaryButton("Join A Family") {
                        // TODO: Handle join family action
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView2()
        .environmentObject(OnboardingViewModel())
}
