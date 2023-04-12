import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    
    private var presenter: MovieQuizPresenter!
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    
    private var statisticService: StatisticService?
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        func alertAction() {
            presenter.resetGame()
            correctAnswers = 0
            imageView.layer.borderWidth = 0
            
            questionFactory?.requestNextQuestion()
        }
        
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        var statisticString = ""
        
        if let statisticService = statisticService
        {
            
            let bestRoundString: String = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n"
            let totalString: String = "Количество сыгранных квизов: \(statisticService.gamesCount)\n"
            let accuracyString: String = "Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            statisticString = totalString + bestRoundString + accuracyString
        }
        
        let alertModel = AlertModel(title: result.title,
                                    message: result.text + statisticString,
                                    buttonText: result.buttonText,
                                    completion: alertAction)
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkAlert(message: error.localizedDescription)
    }
    
    // image loading status
    
    private func showImageLoadingAlert() {
        let imageLoadingAlertModel = AlertModel(title: "Ошибка",
                                                message: "Не удалось загрузить постер",
                                                buttonText: "Попробовать еще раз") {
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: imageLoadingAlertModel)
    }
    
    func didFailToLoadImage() {
        showImageLoadingAlert()
    }
    
    func didLoadImageFromServer() {
        hideLoadingIndicator()
        switchButtons()
    }
    
    // activity indicator
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkAlert(message: String) {

        hideLoadingIndicator()
        let networkAlertModel = AlertModel(title: "Ошибка",
                                           message: message,
                                           buttonText: "Попробовать еще раз") {
            [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetGame()
            self.correctAnswers = 0
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(model: networkAlertModel)
    }
    // нажатие на кнопки "да" и "нет" во время паузы в 1 секунду между вопросами приводило к некорректной работе, на кремя паузы кноаки неактивны
    private func switchButtons() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        switchButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.showNextQuestionOrResults()
            }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers) из \(presenter.questionsAmount)\n",
                buttonText: "Сыграть еще раз")
            
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            imageView.layer.borderWidth = 0

            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchButtons()
        
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: Status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: YES & NO Buttons
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonTapped()
    }
}
