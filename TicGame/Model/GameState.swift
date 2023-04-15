//
//  GameState.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import Foundation

enum GameState {
    case finished, draw, waitingForPlayer, quit
    
    var name: String {
        switch self {
        case .finished:
            return AppStrings.gameHasFinished
        case .draw:
            return AppStrings.draw
        case .waitingForPlayer:
            return AppStrings.waitingForPlayer
        case .quit:
            return AppStrings.playerLeft
        }
    }
}
