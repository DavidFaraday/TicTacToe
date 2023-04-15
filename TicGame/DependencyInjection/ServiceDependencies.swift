//
//  ServiceDependencies.swift
//  TicGame
//
//  Created by David Kababyan on 09/04/2023.
//

import Foundation
import Factory

extension Container {
    
    var firebaseRepository: Factory<FirebaseRepositoryProtocol> {
        self { FirebaseRepository() }
            .shared
    }
}
