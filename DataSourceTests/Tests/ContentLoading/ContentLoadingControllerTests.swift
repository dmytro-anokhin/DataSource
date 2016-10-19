//
//  ContentLoadingControllerTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 13/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ClosureContentLoadingControllerDelegate : ContentLoadingControllerDelegate {

    var willBeginLoading: ((_ controller: ContentLoadingController) -> Void)?
    var didFinishLoadingWithUpdate: ((_ controller: ContentLoadingController, _ update: () -> Void) -> Void)?

    init(willBeginLoading: ((_ controller: ContentLoadingController) -> Void)? = nil,
        didFinishLoadingWithUpdate: ((_ controller: ContentLoadingController, _ update: () -> Void) -> Void)? = nil)
    {
        self.willBeginLoading = willBeginLoading
        self.didFinishLoadingWithUpdate = didFinishLoadingWithUpdate
    }

    func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController) {
        willBeginLoading?(controller)
    }
    
    func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: @escaping () -> Void) {
        didFinishLoadingWithUpdate?(controller, update)
    }
}


class ContentLoadingControllerTests: XCTestCase {

    func testLoadContent() {

        let willBeginLoadingExpectation = expectation(description: "Will begin loading")
        let didFinishLoadingWithUpdateExpectation = expectation(description: "Did finish loading with update")
        
        let controller = ContentLoadingController()
        XCTAssertEqual(controller.loadingState, .initial)
        
        let delegate = ClosureContentLoadingControllerDelegate(
            willBeginLoading: { controller in
                willBeginLoadingExpectation.fulfill()
            },
            didFinishLoadingWithUpdate: { controller, update in
                didFinishLoadingWithUpdateExpectation.fulfill()
            })

        controller.delegate = delegate
        
        controller.loadContent { (coordinator) in
            coordinator.done()
        }
        
        XCTAssertEqual(controller.loadingState, .loadingContent)
        
        waitForExpectations(timeout: 0.1) { error in
            let _ = delegate // Keep strong reference
            XCTAssertEqual(controller.loadingState, .contentLoaded)
        }
    }
    
    func testError() {

        let willBeginLoadingExpectation = expectation(description: "Will begin loading")
        let didFinishLoadingWithUpdateExpectation = expectation(description: "Did finish loading with error")
        
        let controller = ContentLoadingController()
        XCTAssertEqual(controller.loadingState, .initial)
        
        let loadingError = NSError(domain: "ContentLoadingCoordinatorTests", code: 0)
        
        let delegate = ClosureContentLoadingControllerDelegate(
            willBeginLoading: { controller in
                willBeginLoadingExpectation.fulfill()
            },
            didFinishLoadingWithUpdate: { controller, update in
                didFinishLoadingWithUpdateExpectation.fulfill()
            })

        controller.delegate = delegate
        
        controller.loadContent { (coordinator) in
            coordinator.done(withError: loadingError)
        }
        
        XCTAssertEqual(controller.loadingState, .loadingContent)
        
        waitForExpectations(timeout: 0.1) { error in
            let _ = delegate // Keep strong reference
            XCTAssertEqual(controller.loadingState, .error)
            XCTAssertEqual(controller.loadingError as? NSError, loadingError)
        }
    }

    func testIgnore() {

        let willBeginLoadingExpectation = expectation(description: "Will begin loading")
        let ignoreExpectation = expectation(description: "Ignore coordinator")
        
        let controller = ContentLoadingController()
        XCTAssertEqual(controller.loadingState, .initial)
        
        let delegate = ClosureContentLoadingControllerDelegate(
            willBeginLoading: { controller in
                willBeginLoadingExpectation.fulfill()
            },
            didFinishLoadingWithUpdate: { _ in
                XCTFail("Did finish loading should not be called")
            })

        controller.delegate = delegate
        
        controller.loadContent { (coordinator) in
            coordinator.ignore()
            ignoreExpectation.fulfill()
        }
        
        XCTAssertEqual(controller.loadingState, .loadingContent)
        
        waitForExpectations(timeout: 0.1) { error in
            let _ = delegate // Keep strong reference
            XCTAssertEqual(controller.loadingState, .loadingContent)
        }
    }
}
