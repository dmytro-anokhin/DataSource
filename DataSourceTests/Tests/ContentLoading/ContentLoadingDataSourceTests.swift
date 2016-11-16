//
//  ContentLoadingDataSourceTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 02/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingDataSourceTests: XCTestCase {

    class TestDataSource: ContentLoadingDataSource {

        let loadContentClosure: (_ coordinator: ContentLoadingCoordinator) -> Void

        init(loadContentClosure: @escaping (_ coordinator: ContentLoadingCoordinator) -> Void) {
            self.loadContentClosure = loadContentClosure
        }

        override func loadContent() {
            contentLoadingController.loadContent(loadContentClosure)
        }
    }
    
    func testSingleLoad() {

        let contentLoadedExpectation = expectation(description: "Content Loaded")

        let dataSource = TestDataSource { coordinator in

            let delay = drand48() / 10.0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }

                coordinator.done()

                DispatchQueue.main.async {
                    contentLoadedExpectation.fulfill()
                }
            }
        }

        XCTAssertFalse(dataSource.loadingState.isLoading)
        XCTAssertFalse(dataSource.loadingState.isLoaded)

        dataSource.loadContent()

        XCTAssertTrue(dataSource.loadingState.isLoading)

        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(dataSource.loadingState.isLoaded)
        }
    }

    func testMultipleLoads() {

        let contentLoadedExpectation = expectation(description: "Content Loaded")
        let minDelay = 0.01

        let dataSource = TestDataSource { coordinator in

            let delay = max(drand48() / 10.0, minDelay)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }

                coordinator.done()

                DispatchQueue.main.async {
                    contentLoadedExpectation.fulfill()
                }
            }
        }

        XCTAssertFalse(dataSource.loadingState.isLoading)
        XCTAssertFalse(dataSource.loadingState.isLoaded)

        for _ in 0..<10 {
            dataSource.loadContent()
            XCTAssertTrue(dataSource.loadingState.isLoading)

            Thread.sleep(until: Date(timeIntervalSinceNow: minDelay))
        }

        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(dataSource.loadingState.isLoaded)
        }
    }

    func testErrorHandling() {

        let contentLoadedExpectation = expectation(description: "Content Loaded")
        let error = NSError(domain: "ContentLoadingDataSourceTests", code: 0, userInfo: nil)

        let dataSource = TestDataSource { coordinator in

            let delay = drand48() / 10.0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }

                coordinator.done(withError: error)

                DispatchQueue.main.async {
                    contentLoadedExpectation.fulfill()
                }
            }
        }

        XCTAssertFalse(dataSource.loadingState.isLoading)
        XCTAssertFalse(dataSource.loadingState.isLoaded)

        dataSource.loadContent()

        XCTAssertTrue(dataSource.loadingState.isLoading)

        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(dataSource.loadingState, .error)
            XCTAssertEqual(dataSource.loadingError as? NSError, error)
        }
    }
}
