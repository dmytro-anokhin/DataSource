//
//  ExpectationContentLoadingObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 06/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


/// The ExpectationContentLoadingObserver fulfills expectation on ContentLoadingObserver callbacks.
class ExpectationContentLoadingObserver : ContentLoadingObserver {

    var willLoadContentExpectation: XCTestExpectation?
    var didLoadContentExpectation: XCTestExpectation?
    
    init(willLoadContentExpectation: XCTestExpectation? = nil,
        didLoadContentExpectation: XCTestExpectation? = nil)
    {
        self.willLoadContentExpectation = willLoadContentExpectation
        self.didLoadContentExpectation = didLoadContentExpectation
    }

    func willLoadContent(_ sender: ContentLoadingObservable) {
        willLoadContentExpectation?.fulfill()
    }
    
    func didLoadContent(_ sender: ContentLoadingObservable, with error: NSError?) {
        didLoadContentExpectation?.fulfill()
    }
}

