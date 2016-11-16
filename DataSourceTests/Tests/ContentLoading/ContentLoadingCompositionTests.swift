//
//  ContentLoadingCompositionTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingCompositionTests: XCTestCase {

    class TestContentLoader: ContentLoading {

        weak var contentLoadingObserver: ContentLoadingObserver?

        var loadingState: ContentLoadingState = .initial

        var loadingError: Error?

        func loadContent() {

            loadingState = .loading
            contentLoadingObserver?.willLoadContent(self)

            let delay = drand48() / 10.0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if nil != self.loadingError {
                    self.loadingState = .error
                }
                else {
                    self.loadingState = .loaded
                }

                self.contentLoadingObserver?.didLoadContent(self, with: self.loadingError)
            }
        }
    }

    class TestComposition: Composition, ContentLoading, ContentLoadingObserver {

        typealias Child = TestContentLoader

        @discardableResult
        func add(_ child: TestContentLoader) -> Bool {
            children.append(child)
            child.contentLoadingObserver = self

            return true
        }

        @discardableResult
        func remove(_ child: TestContentLoader) -> Bool {
            return false
        }

        private(set) var children: [Child] = []

        weak var contentLoadingObserver: ContentLoadingObserver?

        var loadingError: Error?

        func willLoadContent(_ sender: ContentLoadingObservable) {
        }

        func didLoadContent(_ sender: ContentLoadingObservable, with error: Error?) {
            if loadingState.isLoaded {
                contentLoadingObserver?.didLoadContent(self, with: error)
            }
        }
    }

    func testContentLoading() {

        let firstLoader = TestContentLoader()
        let secondLoader = TestContentLoader()

        let composition = TestComposition()
        composition.add(firstLoader)
        composition.add(secondLoader)

        XCTAssertFalse(composition.loadingState.isLoaded)
        XCTAssertFalse(composition.loadingState.isLoading)

        let willLoadContentExpectation = expectation(description: "Will load content")
        let didLoadContentExpectation = expectation(description: "Did load content")

        let contentLoadingObserver = ClosureContentLoadingObserver()

        contentLoadingObserver.willLoadContent = { _ in
            willLoadContentExpectation.fulfill()
        }

        contentLoadingObserver.didLoadContent = { _ in
            didLoadContentExpectation.fulfill()
        }

        composition.contentLoadingObserver = contentLoadingObserver
        composition.loadContent()

        XCTAssertTrue(composition.loadingState.isLoading)

        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(composition.loadingState.isLoaded)
            XCTAssertTrue(firstLoader.loadingState.isLoaded)
            XCTAssertTrue(secondLoader.loadingState.isLoaded)
            let _ = contentLoadingObserver // keep observer alive
        }
    }
}
