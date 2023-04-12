//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 13.03.2023.
//

import Foundation

import UIKit

class AlertPresenter {

    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController

    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
    
        guard let viewController = viewController else { return }
        
        alert.view.accessibilityIdentifier = "Game Results"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            //[weak self] _ in
            //guard let self = self else { return }
            model.completion()
        }
    
    alert.addAction(action)
    viewController.present(alert, animated: true)
    }
}
