//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Igor on 15.08.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let MostPopularMovies):
                    self.movies = MostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: NetworkError.imageLoadingError)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomQuestion = createQuestion(rating: rating)
            
            let question = QuizQuestion(image: imageData, text: randomQuestion.question,
                correctAnswer: randomQuestion.correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func createQuestion(rating: Float) -> randomQuestion {
        let randomRatingIndex: Int = (2..<10).randomElement() ?? 2
        // false - меньше, true - больше
        let randomRatingDirection = Bool.random()
        let randomDirectionString = randomRatingDirection ? "больше" : "меньше"
        
        let text = "Рейтинг этого фильма \(randomDirectionString) чем \(randomRatingIndex)?"
        let correctAnswer = randomRatingDirection ?
            (rating > Float(randomRatingIndex)) : (rating < Float(randomRatingIndex))

        return randomQuestion(question: text, correctAnswer: correctAnswer)
    }
}
