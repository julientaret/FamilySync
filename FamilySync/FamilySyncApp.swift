//
//  FamilySyncApp.swift
//  FamilySync
//
//  Created by Julien TARET on 02/09/2025.
//

import SwiftUI

@main
struct FamilySyncApp: App {
    @StateObject private var appwriteService = AppwriteService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appwriteService)
        }
    }
}
