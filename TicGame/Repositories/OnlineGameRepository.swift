//
//  OnlineGameRepository.swift
//  TicGame
//
//  Created by David Kababyan on 09/04/2023.
//

import Foundation
import Factory
import Combine

let localPlayerId = UUID().uuidString

final class OnlineGameRepository: ObservableObject {
    @Injected(\.firebaseRepository) private var firebaseRepository
    
    @Published var game: Game!
    
    private var cancellables: Set<AnyCancellable> = []

    @MainActor
    private func createNewGame() async {
        self.game = Game(
            id: UUID().uuidString,
            player1Id: localPlayerId,
            player2Id: "",
            player1Score: 0,
            player2Score: 0,
            activePlayerId: localPlayerId,
            winningPlayerId: "",
            moves: Array(repeating: nil, count: 9)
        )
        
        self.saveOnlineGame()
    }
    
    @MainActor
    func joinGame() async {
        if let gamesToJoin: Game = await getGame() {
            
            self.game = gamesToJoin
            self.game.player2Id = localPlayerId
            self.game.activePlayerId = self.game.player1Id
            
            await updateGame(self.game)
            await listenForChanges(in: self.game.id)
        } else {
            await createNewGame()
            await listenForChanges(in: self.game.id)
        }
    }
    
    @MainActor
    private func listenForChanges(in gameId: String) async {
        do {
            try await firebaseRepository.listen(from: .Game, documentId: gameId)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] game in
                    self?.game = game
                })
                .store(in: &cancellables)
        } catch (let error) {
            print("Error listening \(error.localizedDescription)")
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
    
    func updateGame(_ game: Game) async {
        print("will update \(game)")
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
