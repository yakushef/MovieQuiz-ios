//
//  IMDBModels.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 17.03.2023.
//

import Foundation

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}

struct Movie: Codable {
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]
    
    enum CodingKeys: CodingKey {
        case id, title, year, image, releaseDate, runtimeMins, directors, actorList
    }
    
    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        
        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue
        
        self.image = try container.decode(String.self, forKey: .image)
        self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
        
        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let runtimeMinsValue = Int(runtimeMins) else {
            throw ParseError.runtimeMinsFailure
        }
        self.runtimeMins = runtimeMinsValue
        
        self.directors = try container.decode(String.self, forKey: .directors)
        self.actorList = try container.decode([Actor].self, forKey: .actorList)
    }
}

struct TopMovies: Codable {
    let id: String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: Int
    let image: String
    let crew: String
    let imDbRating: Double
    let imDbRatingCount: Int
    
    enum CodingKeys: CodingKey {
        case id, rank, title, fullTitle, year, image, crew, imDbRating, imDbRatingCount
    }
    
    enum ParseError: Error {
        case rankFailure
        case yearFailure
        case ratingFailure
        case ratingCountFailure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rankValue = Int(rank) else {
            throw ParseError.rankFailure
        }
        self.rank = rankValue
        
        //self.rank = try container.decode(Int.self, forKey: .rank)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.fullTitle = try container.decode(String.self, forKey: .fullTitle)
        
        let year = try container.decode(String.self, forKey: .year)
            guard let yearValue = Int(year) else {
                throw ParseError.yearFailure
            }
            self.year = yearValue
        
        self.image = try container.decode(String.self, forKey: .image)
        self.crew = try container.decode(String.self, forKey: .crew)
        
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let ratingValue = Double(imDbRating) else {
            throw ParseError.ratingFailure
        }
        self.imDbRating = ratingValue
        
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let ratingCount = Int(imDbRatingCount) else {
            throw ParseError.ratingCountFailure
        }
        self.imDbRatingCount = ratingCount
    }
}

struct TopMovieList: Decodable {
    let items: [TopMovies]
}
