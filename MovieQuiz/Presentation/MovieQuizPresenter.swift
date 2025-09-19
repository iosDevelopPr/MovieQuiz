//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Igor on 19.09.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 1
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        self.statisticService = StatisticService()
        
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory?.loadData()
    }
    
    func noButtonClicked() {
        didAnswer(isCorrect: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isCorrect: true)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)"
        )
    }
    
    private func didAnswer(isCorrect: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        self.viewController?.showAnswerResult(isCorrect: isCorrect == currentQuestion.correctAnswer)
    }

    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount + 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 1
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func switchToCorrectAnswers() {
        correctAnswers += 1
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        self.questionFactory?.requestNextQuestion()
    }
    
    func loadData() {
        self.questionFactory?.loadData()
    }
    
    func didFailToLoadData(with error: any Error) {
        switch error {
        case NetworkError.dataLoadingError:
            self.viewController?.showNetworkError(message: "Невозможно загрузить данные")
        case NetworkError.imageLoadingError:
            self.viewController?.showErrorToLoadData(message: "Невозможно загрузить изображение")
        case NetworkError.codeError:
            self.viewController?.showErrorToLoadData(message: "Сервер не смог обработать запрос")
        default:
            self.viewController?.showNetworkError(message: error.localizedDescription)
        }
    }

   func showNextQuestionOrResult() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: messageResultAlert(),
                buttonText: "Сыграть ещё раз"
            )
            self.viewController?.showAlert(quiz: result)
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func messageResultAlert() -> String {
        let bestGame = statisticService.bestGame
        let message =
        "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
            "Количество сыграннных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return message
    }
}
