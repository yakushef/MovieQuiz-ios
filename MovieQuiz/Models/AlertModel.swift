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
    
    init(title: String, message: String, buttonText: String, completion: @escaping ()->Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText 
        self.completion = completion
    }
}
