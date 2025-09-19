import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Private properties

    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let alertPresenter: AlertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupFonts()
        startLoadingData()
    }

    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        startActivityIndicator()
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        startActivityIndicator()
        presenter.yesButtonClicked()
    }
    
    // MARK - Dop function

    private func setupUI() {
        activityIndicator.hidesWhenStopped = true
        startActivityIndicator()
        enabledButton(false)
    }
    
    private func setupFonts() {
        let baseFont = UIFont(name: "YSDisplay-Medium", size: 20)
        let boldFont = UIFont(name: "YSDisplay-Bold", size: 23)
        
        questionTitleLabel.font = baseFont
        indexLabel.font = baseFont
        questionLabel.font = boldFont
        noButton.titleLabel?.font = baseFont
        yesButton.titleLabel?.font = baseFont
    }
    
    private func startLoadingData() {
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    private func enabledButton(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }

    func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
        previewImageView.image = step.image
        
        previewImageView.layer.borderWidth = 0
        
        stopActivityIndicator()
        enabledButton(true)

        presenter.switchToNextQuestion()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.switchToCorrectAnswers()
        }
        
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.borderWidth = 8
        previewImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        enabledButton(false)
        stopActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.startActivityIndicator()
            self.presenter.showNextQuestionOrResult()
        }
    }
    
    func showAlert(quiz result: QuizResultViewModel) {
        
        stopActivityIndicator()
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            
            self.startActivityIndicator()
            self.presenter.didLoadDataFromServer()
        }
        alertPresenter.show(in: self, model: model)
    }

    func showNetworkError(message: String) {
        
        stopActivityIndicator()

        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            
            self.startActivityIndicator()
            self.presenter.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }

    func showErrorToLoadData(message: String) {
        
        stopActivityIndicator()

        let model = AlertModel(title: "Что-то пошло не так(", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.startActivityIndicator()
            self.presenter.didLoadDataFromServer()
        }
        
        alertPresenter.show(in: self, model: model)
    }
}
