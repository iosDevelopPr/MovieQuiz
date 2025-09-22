//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Igor on 22.09.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func showAlert(quiz result: MovieQuiz.QuizResultViewModel) {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func startActivityIndicator() {
        
    }
    
    func stopActivityIndicator() {
        
    }
    
    func enabledButton(isEnabled: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func showErrorToLoadData(message: String) {
        
    }
}
