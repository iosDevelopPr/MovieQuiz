//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Igor on 22.08.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
