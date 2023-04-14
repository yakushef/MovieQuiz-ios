//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 25.03.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies,Error>) -> Void)
}

final class MoviesLoader: MoviesLoading {
    // MARK: - Network Client
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    
        private var top250MoviesUrl: URL {
            guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_5h9d2b6b") else {
                preconditionFailure("Unable to construct Top250MoviesURL")
            }
            return url
        }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
            networkClient.fetch(url: top250MoviesUrl) {result in
                switch result {
                case .success(let data):
                    do {
                        let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                        handler(.success(mostPopularMovies))
                    } catch {
                        handler(.failure(error))
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
    }
    
}
