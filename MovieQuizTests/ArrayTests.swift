//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Aleksey Yakushev on 08.04.2023.
//

import Foundation

import XCTest
@testable import MovieQuiz

class arrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        //Given
        let array = [0, 7, 15, 2, 3]
        //When
        let value = array[safe: 1]
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 7)
    }
    
    func testGetValueOutOfRange() throws {
        //Given
        let array = [10, 23, 7, 1, 2]
        //When
        let value = array[safe: 9]
        //Then
        XCTAssertNil(value)
    }
}
