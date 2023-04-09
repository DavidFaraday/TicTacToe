//
//  GameMove.swift
//  TicGame
//
//  Created by David Kababyan on 08/04/2023.
//

import Foundation

struct GameMove: Codable {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        player == .player1 ? "xmark" : "circle"
    }
}
