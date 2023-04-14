//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 13.03.2023.
//

import UIKit

final class AlertPresenter {

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
            model.completion()
        }
    
    alert.addAction(action)
    viewController.present(alert, animated: true)
    }
}
