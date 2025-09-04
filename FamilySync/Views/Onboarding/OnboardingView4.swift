import SwiftUI

struct OnboardingView4: View {
    @ObservedObject var onboardingViewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                Text("Récapitulatif")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                Text("Vérifiez vos informations avant de commencer")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
            
            // Content
            ScrollView {
                VStack(spacing: 30) {
                    // Profile Section
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#e9906f"))
                            
                            Text("Profil")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 15) {
                            InfoRow(
                                icon: "person.fill",
                                title: "Nom",
                                value: onboardingViewModel.userName.isEmpty ? "Non renseigné" : onboardingViewModel.userName,
                                color: onboardingViewModel.userName.isEmpty ? .red : .green
                            )
                            
                            InfoRow(
                                icon: "calendar",
                                title: "Date de naissance",
                                value: formatDate(onboardingViewModel.userBirthday),
                                color: .green
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    
                    // Family Section
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#e9906f"))
                            
                            Text("Famille")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 15) {
                            if let currentFamily = onboardingViewModel.currentFamily {
                                InfoRow(
                                    icon: "checkmark.circle.fill",
                                    title: "Famille rejointe",
                                    value: currentFamily.name,
                                    color: .green
                                )
                            } else {
                                InfoRow(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Famille",
                                    value: "Aucune famille sélectionnée",
                                    color: .orange
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    
                    // Account Section
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#e9906f"))
                            
                            Text("Compte")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 15) {
                            InfoRow(
                                icon: "checkmark.shield.fill",
                                title: "Authentification",
                                value: "Apple ID connecté",
                                color: .green
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            
            // Bottom Button
            VStack(spacing: 15) {
                Button(action: {
                    onboardingViewModel.completeOnboarding()
                }) {
                    HStack {
                        if onboardingViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(onboardingViewModel.isLoading ? "Configuration..." : "Let's Go!")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#e9906f"))
                    .cornerRadius(25)
                    .shadow(color: Color(hex: "#e9906f").opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(onboardingViewModel.isLoading)
                
                if let errorMessage = onboardingViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingView4(onboardingViewModel: OnboardingViewModel())
}

