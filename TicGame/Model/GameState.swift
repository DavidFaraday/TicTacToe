//
//  GameState.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import Foundation

enum GameState {
    case finished, draw, waitingForPlayer
    
    var name: String {
        switch self {
        case .finished:
            return "The game has finished!"
        case .draw:
            return "It's a draw!"
        case .waitingForPlayer:
            return "Waiting for player"
        }
    }
}
