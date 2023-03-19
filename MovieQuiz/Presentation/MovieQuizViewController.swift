import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    
    private var statisticService: StatisticService?
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        func alertAction() {
            currentQuestionIndex = 0
            correctAnswers = 0
            imageView.layer.borderWidth = 0
            
            questionFactory?.requestNextQuestion()
        }
        
        let alertModel: AlertModel = AlertModel(quizRezult: result, completion: alertAction)
        alertPresenter = AlertPresenter(model: alertModel, viewController: self)
        
        alertPresenter?.showAlert()
    }
    
    // нажатие на кнопки "да" и "нет" во время паузы в 1 секунду между вопросами приводило к некорректной работе, на кремя паузы кноаки неактивны
    private func switchButtons() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        switchButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
            self.switchButtons()
            }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            //мне показалось логичным собрать статистику в этой функции, а не в func show(quiz result: QuizResultsViewModel) как предлагается в учебнике
            //возможно, будет правильнее изменить реализацию AlertModel и передать туда строку статистики в func show(quiz result: QuizResultsViewModel)func show(quiz result: QuizResultsViewModel) ?
            
            var statisticString = ""
            
            if let statisticService = statisticService {
                
                let bestRoundString: String = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n"
                let totalString: String = "Количество сыгранных квизов: \(statisticService.gamesCount)\n"
                let accuracyString: String = "Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%"
                
            statisticString = totalString + bestRoundString + accuracyString
                
            }
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers) из \(questionsAmount)\n" + statisticString,
                buttonText: "Сыграть еще раз")
            
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0

            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // задания по сериализации JSON
    /*
     private func getMovie(from jsonString: String) -> Movie? {
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let movie = try JSONDecoder().decode(Movie.self, from: jsonData)
            return movie
        } catch {
            print("Failed to parse \(jsonString)")
            return nil
        }
    }
    
    private func getTopMovies(from jsonString: String) -> TopMovieList? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let topMovieList = try JSONDecoder().decode(TopMovieList.self, from: jsonData)
            return topMovieList
        } catch {
            print("Failed to parse \(jsonString)")
            return nil
        }
    }
     */
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // задания по сериализации JSON
        /*
        let jsonName: String = "top250MoviesIMDB.json"
        var jsonURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        jsonURL.appendPathComponent(jsonName)
        let jsonString = try? String(contentsOf: jsonURL)
        //print(getMovie(from: jsonString!))
        //print(getTopMovies(from: jsonString!))
        */
        
        statisticService = StatisticServiceImplementation()
    
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // светлый статус-бар чтобы не сливалься с фоном
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
