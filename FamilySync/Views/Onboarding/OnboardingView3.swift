//
//  OnboardingView3.swift
//  FamilySync
//
//  Created by Julien TARET on 04/09/2025.
//

import SwiftUI

struct OnboardingView3: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @State private var userName: String = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground()
            
            VStack(spacing: 40) {
                // Title
                OnboardingTitle(firstLine: "Tell us about", secondLine: "Yourself")
                
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
                        isCompleted: true
                    )
                    
                    OnboardingStep(
                        icon: "checkmark.circle.fill",
                        text: "Set your profile",
                        isCompleted: false
                    )
                }
                
                // Family Illustration
                Image("onboard3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding(.horizontal, 40)
                
                // Input Fields
                VStack(spacing: 20) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What Should We Call You?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(OnboardingColors.primary)
                        
                        TextField("Enter your name", text: $userName)
                            .textFieldStyle(OnboardingTextFieldStyle())
                    }
                    
                    // Birthday Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When Is Your Birthday?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(OnboardingColors.primary)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .contentShape(Rectangle()) // Cette ligne rend toute la zone cliquable
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 40)
                                
                // Continue Button
                Button(action: {
                    onboardingViewModel.handleProfileSetup(name: userName, birthday: selectedDate)
                }) {
                    Text("It's Ok!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#e9906f"))
                        .cornerRadius(10)
                }
                .disabled(userName.isEmpty)
                .opacity(userName.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

// Custom TextField Style
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    OnboardingView3()
        .environmentObject(AuthService.shared)
        .environmentObject(OnboardingViewModel())
}
