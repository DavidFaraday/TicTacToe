//
//  TicGameApp.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI
import Firebase


@main
struct TicGameApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
