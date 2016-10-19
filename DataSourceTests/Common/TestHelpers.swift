//
//  TestHelpers.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 23/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource

    
class TestObserver : UpdateObserver, ContentLoadingObserver {

    var tableView: UITableView
    
    var performUpdateExpectation: XCTestExpectation?
    var willLoadContentExpectation: XCTestExpectation?
    var didLoadContentExpectation: XCTestExpectation?
    
    init(tableView: UITableView,
        performUpdateExpectation: XCTestExpectation? = nil,
        willLoadContentExpectation: XCTestExpectation? = nil,
        didLoadContentExpectation: XCTestExpectation? = nil)
    {
        self.tableView = tableView
        self.performUpdateExpectation = performUpdateExpectation
        self.willLoadContentExpectation = willLoadContentExpectation
        self.didLoadContentExpectation = didLoadContentExpectation
    }

    func perform(update: UpdateType, from sender: UpdateObservable) {
        update.perform(tableView)
        performUpdateExpectation?.fulfill()
    }
    
    func willLoadContent(_ sender: ContentLoadingObservable) {
        willLoadContentExpectation?.fulfill()
    }
    
    func didLoadContent(_ sender: ContentLoadingObservable, with error: Error?) {
        didLoadContentExpectation?.fulfill()
    }
}
