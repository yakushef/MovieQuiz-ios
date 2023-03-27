//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 12.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didLoadImageFromServer()
    func didFailToLoadImage()
}
