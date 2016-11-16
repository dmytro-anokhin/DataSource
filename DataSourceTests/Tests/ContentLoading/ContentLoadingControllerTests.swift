//
//  ContentLoadingControllerTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingControllerTests: XCTestCase {

    class TestContentLoadingControllerDelegate : ContentLoadingControllerDelegate {

        var willBeginLoading: ((ContentLoadingController) -> Void)?

        func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController) {
            willBeginLoading?(controller)
        }

        var didFinishLoadingWithUpdate: ((ContentLoadingController, () -> Void) -> Void)?

        func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: @escaping () -> Void) {
            didFinishLoadingWithUpdate?(controller, update)
        }
    }

    var controller: ContentLoadingController?
    var delegate: TestContentLoadingControllerDelegate?

    var willBeginLoadingExpectation: XCTestExpectation?
    var didFinishLoadingWithUpdate: XCTestExpectation?

    func setExpectations() {
        willBeginLoadingExpectation = expectation(description: "Will begin loading expectation")
        didFinishLoadingWithUpdate = expectation(description: "Did finish loading with update expectation")
    }

    override func setUp() {
        super.setUp()
        controller = ContentLoadingController()

        delegate = TestContentLoadingControllerDelegate()
        delegate?.willBeginLoading = { _ in
            self.willBeginLoadingExpectation?.fulfill()
        }

        delegate?.didFinishLoadingWithUpdate = { controller, update in
            update()
            self.didFinishLoadingWithUpdate?.fulfill()
        }

        controller?.delegate = delegate
    }

    override func tearDown() {
        willBeginLoadingExpectation = nil
        didFinishLoadingWithUpdate = nil

        super.tearDown()
    }

    func testInitialConfiguration() {
        XCTAssertEqual(controller?.loadingState, .initial)
        XCTAssertNil(controller?.loadingError)
    }

    func testContentLoading() {

        setExpectations()

        let updateExpectation = expectation(description: "Update expectation")

        controller?.loadContent { coordinator in

            guard coordinator.current else { return }

            coordinator.done(withUpdate: { 
                updateExpectation.fulfill()
            })
        }

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(self.controller?.loadingState, .loaded)
            XCTAssertNil(self.controller?.loadingError)
        }
    }

    func testError() {

        setExpectations()

        let error = NSError(domain: "ContentLoadingCoordinatorTests", code: 0, userInfo: nil)

        controller?.loadContent { coordinator in
            guard coordinator.current else { return }
            coordinator.done(withError: error)
        }

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(self.controller?.loadingState, .error)
            XCTAssertEqual(self.controller?.loadingError as? NSError, error)
        }
    }

    func testSerialContentLoading() {

        let ignoreExpectation = expectation(description: "Ignore expectation")
        let updateExpectation = expectation(description: "Update expectation")

        // First loading will complete after 100ms
        controller?.loadContent { coordinator in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {

                guard coordinator.current else {
                    coordinator.ignore()
                    ignoreExpectation.fulfill()
                    return
                }

                coordinator.done()
            })
        }

        // Second loading will complete after 50ms
        controller?.loadContent { coordinator in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.05, execute: {

                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }

                coordinator.done(withUpdate: { 
                    updateExpectation.fulfill()
                })
            })
        }

        waitForExpectations(timeout: 0.5) { _ in
            XCTAssertEqual(self.controller?.loadingState, .loaded)
            XCTAssertNil(self.controller?.loadingError)
        }
    }
}
