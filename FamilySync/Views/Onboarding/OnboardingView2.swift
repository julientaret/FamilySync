//
//  OnboardingView2.swift
//  FamilySync
//
//  Created by Julien TARET on 04/09/2025.
//

import SwiftUI

struct OnboardingView2: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground()
            
            VStack(spacing: 40) {
                // Title
                OnboardingTitle(firstLine: "Create or Join", secondLine: "Your Family")
                
                // Steps
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
                
                // Family Illustration
                Image("onboard2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)
                    .padding(.horizontal, 40)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        onboardingViewModel.nextStep()
                    }) {
                        Text("Create New Family")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#e9906f"))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        onboardingViewModel.nextStep()
                    }) {
                        Text("Join Existing Family")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#e9906f"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(hex: "#e9906f"), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView2()
        .environmentObject(AuthService.shared)
        .environmentObject(OnboardingViewModel())
}
