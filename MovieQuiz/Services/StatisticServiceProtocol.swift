//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Igor on 17.08.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
    func messageResultAlert(correct count: Int, total amount: Int) -> String
}
