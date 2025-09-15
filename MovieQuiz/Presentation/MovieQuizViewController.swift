import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Private properties

    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 1
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupFonts()
        startLoadingData()
    }

    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    // MARK - Dop function

    private func setupUI() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        enabledButton(false)
    }
    
    private func setupFonts() {
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }
    
    private func startLoadingData() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    private func enabledButton(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // MARK - Function VC

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
        previewImageView.image = step.image
        
        previewImageView.layer.borderWidth = 0
        
        activityIndicator.stopAnimating()
        enabledButton(true)

        currentQuestionIndex += 1
   }
    
    private func showAnswerResult(isCorrect: Bool) {
        correctAnswers = correctAnswers + (isCorrect ? 1 : 0)
        
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.borderWidth = 8
        previewImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        enabledButton(false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.startAnimating()
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex <= questionsAmount {
            questionFactory?.requestNextQuestion()
        } else {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: messageResultAlert(),
                buttonText: "Сыграть ещё раз"
            )
            showAlert(quiz: result)
        }
    }
    
    private func showAlert(quiz result: QuizResultViewModel) {
        
        activityIndicator.stopAnimating()
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 1
            self.correctAnswers = 0
            
            self.activityIndicator.startAnimating()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.show(in: self, model: model)
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
    
    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    private func showNetworkError(message: String) {
        
        activityIndicator.stopAnimating()

        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 1
            self.correctAnswers = 0
            
            self.activityIndicator.startAnimating()
            self.questionFactory?.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }

    private func showErrorToLoadData(message: String) {
        
        activityIndicator.stopAnimating()

        let model = AlertModel(title: "Что-то пошло не так(", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.startAnimating()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }

    func didFailToLoadData(with error: any Error) {
        switch error {
        case NetworkError.dataLoadingError:
            showErrorToLoadData(message: "Невозможно загрузить данные")
        case NetworkError.imageLoadingError:
            showErrorToLoadData(message: "Невозможно загрузить изображение")
        case NetworkError.codeError:
            showErrorToLoadData(message: "Сервер не смог обработать запрос")
        default:
            showNetworkError(message: error.localizedDescription)
        }
    }
}
