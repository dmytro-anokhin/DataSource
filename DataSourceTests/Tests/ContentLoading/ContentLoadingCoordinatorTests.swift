//
//  ContentLoadingCoordinatorTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingCoordinatorTests: XCTestCase {

    var coordinator: ContentLoadingCoordinator?

    var resultLoadingState: ContentLoadingState?
    var resultError: Error?

    override func setUp() {
        super.setUp()

        let completionExpectation = expectation(description: "Completion expectation")

        coordinator = ContentLoadingCoordinator { state, error, update in
            self.resultLoadingState = state
            self.resultError = error

            update?()

            completionExpectation.fulfill()
        }
    }

    override func tearDown() {
        resultLoadingState = nil
        resultError = nil

        super.tearDown()
    }

    func testDoneWithUpdate() {

        let updateExpectation = expectation(description: "Update expectation")

        coordinator?.done {
            updateExpectation.fulfill()
        }

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(self.resultLoadingState, .loaded)
            XCTAssertNil(self.resultError)
        }
    }

    func testDoneWithError() {

        let error = NSError(domain: "ContentLoadingCoordinatorTests", code: 0, userInfo: nil)
        coordinator?.done(withError: error)

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(self.resultLoadingState, .error)
            XCTAssertEqual(self.resultError as? NSError, error)
        }
    }

    func testIgnore() {

        coordinator?.ignore()

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertNil(self.resultLoadingState)
            XCTAssertNil(self.resultError)
        }
    }
}
