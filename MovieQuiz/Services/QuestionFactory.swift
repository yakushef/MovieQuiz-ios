//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 10.03.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    private var movieQuestionsUnasked: [MostPopularMovie] = []
    
    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoading) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        self.movies = []
            moviesLoader.loadMovies() { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error)
                        return
                    }
                }
            }
    }
    
    func requestNextQuestion() {
        
        if movieQuestionsUnasked.count < 1 {
            movieQuestionsUnasked = movies
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0 ..< self.movieQuestionsUnasked.count).randomElement() ?? 0
            
            guard let movie = self.movieQuestionsUnasked[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImage)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didLoadImageFromServer()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadImage()
                }
                print("Failed to load image")
            }
            
            let questionRating = Int.random(in: 7...9)
            let questionIsMore: Bool = Bool.random()
            let rating = Float(movie.rating) ?? 0
            
            let text = questionIsMore ? "Рейтинг этого фильма больше, чем \(questionRating)?" : "Рейтинг этого фильма меньше, чем \(questionRating)?"
            let correctAnswer = questionIsMore ? rating > Float(questionRating) : rating < Float(questionRating)
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            self.movieQuestionsUnasked.remove(at: index)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
        
    }
}
