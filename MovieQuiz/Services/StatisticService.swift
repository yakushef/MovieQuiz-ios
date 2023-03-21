//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aleksey Yakushev on 18.03.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBeaten(by newRecord: GameRecord) -> Bool {
        return newRecord.correct > self.correct
    }
}

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        guard let correctData = userDefaults.data(forKey: Keys.correct.rawValue),
              let correct = try? decoder.decode(Int.self, from: correctData),
              let totalData = userDefaults.data(forKey: Keys.total.rawValue),
              let total = try? decoder.decode(Int.self, from: totalData),
              total > 0 else {
            return 0.0
        }
        return 100.0 * Double(correct) / Double(total)
    }

    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let currentCount = try? decoder.decode(Int.self, from: data) else {
                return 0
            }
            return currentCount
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно обновить число сыгранных раундов")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? decoder.decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private var correct: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.correct.rawValue),
                  let currentCorrect = try? decoder.decode(Int.self, from: data) else {
                return 0
            }
            return currentCorrect
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно обновить число правильных ответов")
                return
            }
            userDefaults.set(data, forKey: Keys.correct.rawValue)
        }
    }
    
    private var total: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let currentTotal = try? decoder.decode(Int.self, from: data) else {
                return 0
            }
            return currentTotal
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно обновить число заданных вопросов")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correct += count
        total += amount
        gamesCount += 1
        
        let oldRecord: GameRecord = bestGame
        let newScore: GameRecord = GameRecord(correct: count, total: amount, date: Date())
        guard oldRecord.isBeaten(by: newScore) else { return }
        bestGame = newScore
    }
    
}
