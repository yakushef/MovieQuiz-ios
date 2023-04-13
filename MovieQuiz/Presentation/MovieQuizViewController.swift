import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highthightImageBorder(isCorrect: Bool)
    func clearImageBorder()
    
    func readyForNextQuestion()
    
    func showLoadingIndicator()
    
    func showImageLoadingAlert()
    func showNetworkAlert(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter!
    
    // MARK: Show
    
    func show(quiz step: QuizStepViewModel) {
        clearImageBorder()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {

        let message = presenter.makeStatisticsString()
        
        let alertModel = AlertModel(title: result.title,
                                    message: result.text + message,
                                    buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.presenter.resetGame()
        }
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: Status Indications
    
    func readyForNextQuestion() {
        hideLoadingIndicator()
        switchButtons()
    }
    
    // activity indicator
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func highthightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        switchButtons()
    }
    
    func clearImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    // MARK: Alerts
    
    func showImageLoadingAlert() {
        let imageLoadingAlertModel = AlertModel(title: "Ошибка",
                                                message: "Не удалось загрузить постер",
                                                buttonText: "Попробовать еще раз") {
            self.presenter.tryToLoadImage()
        }
        alertPresenter.showAlert(model: imageLoadingAlertModel)
    }
    
    func showNetworkAlert(message: String) {

        hideLoadingIndicator()
        let networkAlertModel = AlertModel(title: "Ошибка",
                                           message: message,
                                           buttonText: "Попробовать еще раз") {
            [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetGame()
            self.presenter.startLoadingData()
        }
        alertPresenter?.showAlert(model: networkAlertModel)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchButtons()
        
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: Status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: YES & NO Buttons
    
    // нажатие на кнопки "да" и "нет" во время паузы в 1 секунду между вопросами приводило к некорректной работе, на кремя паузы кноаки неактивны
    private func switchButtons() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonTapped()
    }
}
