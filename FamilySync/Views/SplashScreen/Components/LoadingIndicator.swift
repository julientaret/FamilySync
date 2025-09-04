//
//  LoadingIndicator.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Spinner
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            // Loading text
            Text("Connecting...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.8, blue: 0.8),
                Color(red: 1.0, green: 0.9, blue: 0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        LoadingIndicator()
    }
}
