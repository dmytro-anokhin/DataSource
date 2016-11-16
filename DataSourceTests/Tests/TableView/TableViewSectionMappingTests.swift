//
//  TableViewSectionMappingTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 03/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class TableViewSectionMappingTests: XCTestCase {

    func testUpdateMapping() {

        let numberOfSectionsOutsideDataSource = 10
        let numberOfSectionsInsideDataSource = 5

        let dataSource = TestTableViewDataSource()
        let mapping = TableViewSectionMapping(dataSource: dataSource)

        XCTAssertEqual(mapping.sectionCount, 0)
        XCTAssertEqual(mapping.updateMappings(startingWith: numberOfSectionsOutsideDataSource),
            numberOfSectionsOutsideDataSource)
        XCTAssertEqual(mapping.sectionCount, dataSource.numberOfSections)

        dataSource.numberOfSections = numberOfSectionsInsideDataSource

        XCTAssertEqual(mapping.sectionCount, 0)
        XCTAssertEqual(mapping.updateMappings(startingWith: numberOfSectionsOutsideDataSource),
            numberOfSectionsOutsideDataSource + numberOfSectionsInsideDataSource)
        XCTAssertEqual(mapping.sectionCount, dataSource.numberOfSections)
    }

    func testEquality() {

        let firstDataSource = TestTableViewDataSource()
        let secondDataSource = TestTableViewDataSource()

        let firstMapping1 = TableViewSectionMapping(dataSource: firstDataSource)
        let firstMapping2 = TableViewSectionMapping(dataSource: firstDataSource)
        let secondMapping = TableViewSectionMapping(dataSource: secondDataSource)

        let _ = firstMapping1.updateMappings(startingWith: 0)
        let _ = firstMapping2.updateMappings(startingWith: 0)
        let _ = secondMapping.updateMappings(startingWith: 0)

        XCTAssertNotEqual(firstMapping1, secondMapping)
        XCTAssertEqual(firstMapping1, firstMapping2)
    }

    func testSectionMapping() {

        let numberOfSectionsOutsideDataSource = 10
        let numberOfSectionsInsideDataSource = 5

        let dataSource = TestTableViewDataSource()
        dataSource.numberOfSections = numberOfSectionsInsideDataSource

        let mapping = TableViewSectionMapping(dataSource: dataSource)
        let _ = mapping.updateMappings(startingWith: numberOfSectionsOutsideDataSource)

        // Local to global

        let localSections = IndexSet(integersIn: 0..<dataSource.numberOfSections)
        let expectedGlobalSections = IndexSet(integersIn:
            numberOfSectionsOutsideDataSource..<numberOfSectionsOutsideDataSource + dataSource.numberOfSections)

        XCTAssertEqual(mapping.globalSections(for: localSections), expectedGlobalSections)

        // Global to local

        let globalSections = IndexSet(integersIn: 0..<numberOfSectionsOutsideDataSource + dataSource.numberOfSections)
        let expectedLocalSections = IndexSet(integersIn: 0..<dataSource.numberOfSections)

        XCTAssertEqual(mapping.localSections(for: globalSections), expectedLocalSections)

        // Global section not in data source

        XCTAssertNil(mapping.localSection(for: 100))
    }

    func testIndexPathMapping() {

        let numberOfSectionsOutsideDataSource = 10
        let numberOfSectionsInsideDataSource = 5
        let numberOfRowsInsideSection = 4

        let dataSource = TestTableViewDataSource()
        dataSource.numberOfSections = numberOfSectionsInsideDataSource

        let mapping = TableViewSectionMapping(dataSource: dataSource)
        let _ = mapping.updateMappings(startingWith: numberOfSectionsOutsideDataSource)

        // Local to global

        let localIndexPaths: [IndexPath] = (0..<dataSource.numberOfSections).reduce([]) { indexPaths, section in
            indexPaths + (0..<numberOfRowsInsideSection).map { row in
                IndexPath(row: row, section: section)
            }
        }

        let expectedGlobalSections = (numberOfSectionsOutsideDataSource..<numberOfSectionsOutsideDataSource + dataSource.numberOfSections)
        let expectedGlobalIndexPaths: [IndexPath] = expectedGlobalSections.reduce([]) { indexPaths, section in
            indexPaths + (0..<numberOfRowsInsideSection).map { row in
                IndexPath(row: row, section: section)
            }
        }

        XCTAssertEqual(mapping.globalIndexPaths(for: localIndexPaths), expectedGlobalIndexPaths)

        // Global to local

        let globalSections = (numberOfSectionsOutsideDataSource..<numberOfSectionsOutsideDataSource + dataSource.numberOfSections)
        let globalIndexPaths: [IndexPath] = globalSections.reduce([]) { indexPaths, section in
            indexPaths + (0..<numberOfRowsInsideSection).map { row in
                IndexPath(row: row, section: section)
            }
        }

        let expectedLocalIndexPaths: [IndexPath] = (0..<dataSource.numberOfSections).reduce([]) { indexPaths, section in
            indexPaths + (0..<numberOfRowsInsideSection).map { row in
                IndexPath(row: row, section: section)
            }
        }

        XCTAssertEqual(mapping.localIndexPaths(for: globalIndexPaths), expectedLocalIndexPaths)

        // Global index path not in data source

        XCTAssertNil(mapping.localIndexPath(for: IndexPath(row: 0, section: 100)))
    }
}
