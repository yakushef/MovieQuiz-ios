//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 13.03.2023.
//

import Foundation

import UIKit

class AlertPresenter {
    let model: AlertModel
    let viewController: UIViewController
    
    init(model: AlertModel, viewController: UIViewController) {
        self.viewController = viewController
        self.model = model
        }
    
func showAlert() {
    let alert = UIAlertController(title: self.model.title,
                                  message: self.model.message,
                                  preferredStyle: .alert)
    
    let action = UIAlertAction(title: self.model.buttonText, style: .default) {
        // [weak self] _ in
        //guard let self = self else { return }
        _ in
        self.model.completion()
    }
    
    alert.addAction(action)
    viewController.present(alert, animated: true)
}
}
