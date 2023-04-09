//
//  GameMode.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import SwiftUI

enum GameMode: CaseIterable, Identifiable {
    var id: Self { return self }

    case vsHuman, vsCPU, online
    
    var name: String {
        switch self {
        case .vsHuman:
            return "VS Human"
        case .vsCPU:
            return "VS CPU"
        case .online:
            return "Online"
        }
    }
    
    var color: Color {
        switch self {
        case .vsHuman:
            return Color.blue
        case .vsCPU:
            return Color.red
        case .online:
            return Color.green
        }
    }
}
