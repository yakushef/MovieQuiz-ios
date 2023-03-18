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
            let viewModel = QuizResultsViewModel(
                title: "Этот раугд окончен!",
                text: "Ваш результат \(correctAnswers) из \(questionsAmount)",
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0

            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func getMovie(from jsonString: String) -> Movie? {
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            guard let json = json,
                  let id = json["id"] as? String,
                  let title = json["title"] as? String,
                  let jsonYear = json["year"] as? String,
                  let year = Int(jsonYear),
                  let image = json["image"] as? String,
                  let releaseDate = json["releaseDate"] as? String,
                  let jsonRuntimeMins = json["runtimeMins"] as? String,
                  let runtimeMins = Int(jsonRuntimeMins),
                  let directors = json["directors"] as? String,
                  let actorList = json["actorList"] as? [Any] else {
                return nil
            }
            
            var movieActors: [Actor] = []
            
            for actor in actorList {
                guard let actor = actor as? [String: Any],
                      let id = actor["id"] as? String,
                      let image = actor["image"] as? String,
                      let name = actor["name"] as? String,
                      let asCharacter = actor["asCharacter"] as? String else {
                    return nil
                }
                let movieActor = Actor(id: id, image: image, name: name, asCharacter: asCharacter)
                movieActors.append(movieActor)
            }
            
            let movie = Movie(id: id, title: title, year: year, image: image, releaseDate: releaseDate, runtimeMins: runtimeMins, directors: directors, actorList: movieActors)
            return movie
            
        } catch {
            print("Failed to parse \(jsonString)")
            return nil
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonName: String = "inception.json"
        var jsonURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        jsonURL.appendPathComponent(jsonName)
        let jsonString = try? String(contentsOf: jsonURL)
        //print(getMovie(from: jsonString!))
        //let jsonData = jsonString!.data(using: .utf8)!
        
        //поправить распаковку
        
       /* do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            let actorList = json?["actorList"] as! [Any]
            for actor in actorList {
                if let actor = actor as? [String: Any] {
                    print(actor["name"])
                }
            }
        } catch {
            print("Failed to parse \(jsonString!)")
        }*/
    
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
