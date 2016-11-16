//
//  ContentLoadingTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingTests: XCTestCase {

    func testContentLoadingState() {

        XCTAssertFalse(ContentLoadingState.initial.isLoading)
        XCTAssertFalse(ContentLoadingState.initial.isLoaded)

        XCTAssertTrue(ContentLoadingState.loading.isLoading)
        XCTAssertFalse(ContentLoadingState.loading.isLoaded)

        XCTAssertFalse(ContentLoadingState.loaded.isLoading)
        XCTAssertTrue(ContentLoadingState.loaded.isLoaded)

        XCTAssertFalse(ContentLoadingState.error.isLoading)
        XCTAssertTrue(ContentLoadingState.error.isLoaded)
    }
    
}
