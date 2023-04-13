//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Aleksey Yakushev on 12.04.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func highthightImageBorder(isCorrect: Bool) {
        
    }
    
    func clearImageBorder() {
        
    }
    
    func readyForNextQuestion() {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func showImageLoadingAlert() {
        
    }
    
    func showNetworkAlert(message: String) {
        
    }
    
    
}

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        //Given
        let vcMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: vcMock)
        
        let emptyData = Data()
        //When
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        //Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1 / 10")
    }

}
