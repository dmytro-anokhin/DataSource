//
//  ContentLoadingCoordinatorTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 12/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingCoordinatorTests: XCTestCase {

    func testDoneWithUpdate() {
        
        let updateExpectation = expectation(description: "Update expectation")
        
        let coordinator = ContentLoadingCoordinator { (state, error, update) in
            XCTAssertEqual(state, .contentLoaded)
            update?()
        }
        
        coordinator.done { 
            updateExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testDoneWithError() {
        
        let errorExpectation = expectation(description: "Error expectation")
        let loadingError = NSError(domain: "ContentLoadingCoordinatorTests", code: 0)
        
        let coordinator = ContentLoadingCoordinator { (state, error, update) in
            XCTAssertEqual(state, .error)
            XCTAssertEqual(loadingError, error as? NSError)
            errorExpectation.fulfill()
        }
        
        coordinator.done(withError: loadingError)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testIgnore() {
        
        let ignoreExpectation = expectation(description: "Ignore expectation")
        
        let coordinator = ContentLoadingCoordinator { (state, error, update) in
            XCTAssertNil(state)
            XCTAssertNil(error)
            XCTAssertNil(update)
            ignoreExpectation.fulfill()
        }
        
        coordinator.ignore()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testMultipleCalls() {

        // The `ContentLoadingCoordinator` must handle only first call and ignore subsequent calls

        let updateExpectation = expectation(description: "Update expectation")
        
        var firstCallHandled = false
        var secondCallHandled = false
        
        let coordinator = ContentLoadingCoordinator { (state, error, update) in
            XCTAssertEqual(state, .contentLoaded)
            update?()
        }
        
        coordinator.done {
            firstCallHandled = true
            updateExpectation.fulfill()
        }
        
        coordinator.done {
            secondCallHandled = true
            updateExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.1) { error in
            XCTAssertTrue(firstCallHandled)
            XCTAssertFalse(secondCallHandled)
        }
    }
}
