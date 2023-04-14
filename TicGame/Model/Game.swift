//
//  Game.swift
//  TicGame
//
//  Created by David Kababyan on 09/04/2023.
//

import Foundation

struct Game: Codable, Identifiable {
    let id: String
    
    var player1Id: String
    var player2Id: String
    
    var player1Score: Int
    var player2Score: Int
    
    var activePlayerId: String
    var winningPlayerId: String
    
    var moves: [GameMove?]
}

