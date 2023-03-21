//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 13.03.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
    
    init(quizRezult: QuizResultsViewModel, statisticString: String, completion: @escaping () -> Void) {
        self.title = quizRezult.title
        self.message = quizRezult.text + statisticString
        self.buttonText = quizRezult.buttonText
        self.completion = completion
    }
}
