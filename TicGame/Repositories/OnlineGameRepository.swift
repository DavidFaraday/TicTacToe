//
//  OnlineGameRepository.swift
//  TicGame
//
//  Created by David Kababyan on 09/04/2023.
//

import Foundation
import Factory

let localPlayerId = "LocalPlayerId"

final class OnlineGameRepository: ObservableObject {
    @Injected(\.firebaseRepository) private var firebaseRepository
    
    @Published var game: Game!
    
    private func createNewGame() {
        self.game = Game(
            id: UUID().uuidString,
            player1Id: localPlayerId,
            player2Id: "",
            blockMoveForPlayerId: localPlayerId,
            winningPlayerId: "",
            rematchPlayerId: [],
            moves: Array(repeating: nil, count: 9)
        )
        
        self.saveOnlineGame()
        //        self.listenForGameChanges()
    }
    
    func joinGame() async {
        if let gamesToJoin: Game = await getGame() {
            
            self.game = gamesToJoin
            self.game.player2Id = localPlayerId
            self.game.blockMoveForPlayerId = localPlayerId
            
            updateGame(self.game)
            ///listen for changes
        } else {
            createNewGame()
        }
    }
    
    
    private func getGame() async -> Game? {
        return try? await firebaseRepository.getDocuments(from: .Game, for: localPlayerId)?.first
    }
    
    private func saveOnlineGame() {
        do {
            try firebaseRepository.saveData(data: game, to: .Game)
        } catch {
            print("Error saving Game", error.localizedDescription)
        }
    }
    

    private func updateGame(_ game: Game) {
        do {
            try firebaseRepository.saveData(data: game, to: .Game)
        } catch {
            print("Error updating online game", error.localizedDescription)
        }
    }

    private func quiteGame() {
//        guard game != nil else { return }
        firebaseRepository.deleteDocument(with: self.game.id, from: .Game)
    }
}
