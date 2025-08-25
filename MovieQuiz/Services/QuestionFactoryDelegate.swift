//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Igor on 22.08.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRReceiveNextQuestion(question: QuizQuestion?)
}
