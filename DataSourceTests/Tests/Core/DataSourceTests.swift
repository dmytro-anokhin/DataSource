//
//  DataSourceTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 02/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class DataSourceTests: XCTestCase {
    
    func testSingleUpdate() {

        let updateExpectation = expectation(description: "Update")
        let update = ArbitraryUpdate {
            updateExpectation.fulfill()
        }

        let updateObserver = ClosureUpdateObserver { update, sender in
            update.perform(UIView(frame: .zero))
        }

        let dataSource = DataSource()
        dataSource.updateObserver = updateObserver
        dataSource.notifyUpdate(update)

        waitForExpectations(timeout: 1.0) { _ in
            let _ = updateObserver // keep strong reference to observer
        }
    }

    func testMultipleUpdates() {

        class PostponeUpdateDataSource: DataSource {

            private var _shouldPostponeUpdate: Bool = false

            override var shouldPostponeUpdate: Bool {
                get {
                    return _shouldPostponeUpdate
                }

                set {
                    _shouldPostponeUpdate = newValue

                    if !shouldPostponeUpdate {
                        performPendingUpdate()
                    }
                }
            }
        }

        let updateObserver = ClosureUpdateObserver { update, sender in
            update.perform(UIView(frame: .zero))
        }

        let dataSource = PostponeUpdateDataSource()
        dataSource.shouldPostponeUpdate = true
        dataSource.updateObserver = updateObserver

        for _ in 0..<10 {

            let updateExpectation = expectation(description: "Update")
            let update = ArbitraryUpdate {
                updateExpectation.fulfill()
            }

            dataSource.notifyUpdate(update)
        }

        dataSource.shouldPostponeUpdate = false

        waitForExpectations(timeout: 1.0) { _ in
            let _ = updateObserver // keep strong reference to observer
        }
    }

    func testContentLoadingUpdate() {

        class ContentLoadingDataSource: DataSource, ContentLoading {

            override init() {
                loadingState = .initial
            }

            weak var contentLoadingObserver: ContentLoadingObserver?

            var loadingState: ContentLoadingState {
                didSet {
                    if loadingState.isLoading {
                        contentLoadingObserver?.willLoadContent(self)
                    }

                    if loadingState.isLoaded {
                        performPendingUpdate()
                        contentLoadingObserver?.didLoadContent(self, with: loadingError)
                    }
                }
            }

            var loadingError: Error? = nil

            func loadContent() {
            }
        }

        let willLoadExpectation = expectation(description: "Will Load")
        let didLoadExpectation = expectation(description: "Did Load")

        let contentLoadingObserver = ClosureContentLoadingObserver(
            willLoadContent: { _ in
                willLoadExpectation.fulfill()
            },
            didLoadContent: { _ in
                didLoadExpectation.fulfill()
            })

        let updateObserver = ClosureUpdateObserver { update, sender in
            update.perform(UIView(frame: .zero))
        }

        let dataSource = ContentLoadingDataSource()
        dataSource.updateObserver = updateObserver
        dataSource.contentLoadingObserver = contentLoadingObserver

        dataSource.loadingState = .loading

        for _ in 0..<10 {

            let updateExpectation = expectation(description: "Update")
            let update = ArbitraryUpdate {
                updateExpectation.fulfill()
            }

            dataSource.notifyUpdate(update)
        }

        let delay = drand48() / 10.0

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            dataSource.loadingState = .loaded
        }

        waitForExpectations(timeout: 1.0) { _ in
            // keep strong references to observers
            let _ = updateObserver
            let _ = contentLoadingObserver
        }

    }
}
