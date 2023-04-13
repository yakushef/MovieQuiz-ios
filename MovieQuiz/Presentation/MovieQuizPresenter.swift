//
//  MovieQuizViewPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 10.04.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticService!

    
    init(viewController: MovieQuizViewControllerProtocol?) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        
        startLoadingData()
    }
    
    // MARK: Base Methods
    
    func startLoadingData() {
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkAlert(message: error.localizedDescription)
    }
    
    func didLoadImageFromServer() {
        viewController?.readyForNextQuestion()
    }
    
    func didFailToLoadImage() {
        viewController?.showImageLoadingAlert()
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers) из \(questionsAmount)\n",
                buttonText: "Сыграть еще раз")
            
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            viewController?.clearImageBorder()
            viewController?.showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Alert resources
    
    func makeStatisticsString() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestRoundString: String = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let totalString: String = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let accuracyString: String = "Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let statisticString = [totalString, bestRoundString, accuracyString].joined(separator: "\n")
        
        return statisticString
    }
    
    func tryToLoadImage() {
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: Answer Handling
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.showNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    // MARK: Yes & No buttons
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonTapped() {
        didAnswer(isYes: true)
    }
    
    func noButtonTapped() {
        didAnswer(isYes: false)
    }
}
