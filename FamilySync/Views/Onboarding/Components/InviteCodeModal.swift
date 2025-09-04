import SwiftUI

/// Modal pour afficher le code d'invitation généré
struct InviteCodeModal: View {
    @EnvironmentObject var familyViewModel: FamilyManagementViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("Famille créée !")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Votre famille a été créée avec succès")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Family Info
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Nom de la famille")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(familyViewModel.currentFamily?.name ?? "")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#e9906f"))
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        Text("Code d'invitation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Partagez ce code avec les membres de votre famille")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Code Display
                        VStack(spacing: 8) {
                            Text(familyViewModel.generatedInviteCode)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "#e9906f"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#e9906f").opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#e9906f"), lineWidth: 2)
                                        )
                                )
                            
                            Button(action: {
                                UIPasteboard.general.string = familyViewModel.generatedInviteCode
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copier le code")
                                }
                                .font(.caption)
                                .foregroundColor(Color(hex: "#e9906f"))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Passer à l'étape suivante de l'onboarding
                        onboardingViewModel.currentFamily = familyViewModel.currentFamily
                        onboardingViewModel.nextStep()
                        familyViewModel.closeAllModals()
                    }) {
                        Text("Continuer")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#e9906f"))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        familyViewModel.closeAllModals()
                    }) {
                        Text("Fermer")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    InviteCodeModal()
        .environmentObject(FamilyManagementViewModel())
        .environmentObject(OnboardingViewModel())
}

