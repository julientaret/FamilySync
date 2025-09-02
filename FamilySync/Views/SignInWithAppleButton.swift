import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: View {
    @ObservedObject var appleSignInService: AppleSignInService
    
    var body: some View {
        VStack {
            SignInWithAppleButtonViewRepresentable()
                .frame(height: 50)
                .onTapGesture {
                    appleSignInService.signInWithApple()
                }
                .disabled(appleSignInService.isLoading)
            
            if appleSignInService.isLoading {
                ProgressView("Signing in...")
                    .padding()
            }
            
            if let errorMessage = appleSignInService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // No updates needed
    }
}