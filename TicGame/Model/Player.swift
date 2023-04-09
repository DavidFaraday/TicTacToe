//
//  Player.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import Foundation

enum Player: Codable {
    case player1, player2, cpu
    
    var name: String {
        switch self {
        case .player1:
            return "Player1"
        case .player2:
            return "Player2"
        case .cpu:
            return "Computer"
        }
    }
}
