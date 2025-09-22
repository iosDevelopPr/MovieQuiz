//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Igor on 22.09.2025.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(quiz result: QuizResultViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func startActivityIndicator()
    func stopActivityIndicator()
    func enabledButton(isEnabled: Bool)
    
    func showNetworkError(message: String)
    func showErrorToLoadData(message: String)
}
