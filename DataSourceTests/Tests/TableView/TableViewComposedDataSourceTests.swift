//
//  TableViewComposedDataSourceTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 08/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class TableViewComposedDataSourceTests: XCTestCase {

    func testTableViewComposedDataSource() {

        let firstDataSource = TestTableViewDataSource()
        firstDataSource.sections = [0, 0]
        let secondDataSource = TestTableViewDataSource()
        secondDataSource.sections = [0]

        let composedDataSource = TableViewComposedDataSource()
        composedDataSource.add(firstDataSource)
        composedDataSource.add(secondDataSource)

        XCTAssertEqual(composedDataSource.numberOfSections, 3)
    }

    func testAddRemove() {

        let composedDataSource = TableViewComposedDataSource()
        XCTAssertEqual(composedDataSource.numberOfSections, 0)

        let dataSource = TestTableViewDataSource()
        dataSource.sections = [0]

        composedDataSource.add(dataSource)
        XCTAssertEqual(composedDataSource.numberOfSections, 1)

        composedDataSource.remove(dataSource)
        XCTAssertEqual(composedDataSource.numberOfSections, 0)
    }
}
