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
        let array = [1, 1, 2, 3, 5]
        //When
        let value = array[safe: 2]
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        //Given
        let array = [1, 1, 2, 3, 5]
        //When
        let value = array[safe: 9]
        //Then
        XCTAssertNil(value)
    }
}
