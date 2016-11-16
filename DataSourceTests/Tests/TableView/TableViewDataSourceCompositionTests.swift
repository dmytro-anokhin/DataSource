//
//  TableViewDataSourceCompositionTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 08/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class TableViewDataSourceCompositionTests: XCTestCase {
    
    func testComposition() {

        let firstDataSource = TestTableViewDataSource()
        firstDataSource.sections = [2]

        let secondDataSource = TestTableViewDataSource()
        secondDataSource.sections = []

        let thirdDataSource = TestTableViewDataSource()
        thirdDataSource.sections = [1, 1]

        let composition = TableViewDataSourceComposition()
        XCTAssertTrue(composition.add(firstDataSource))
        XCTAssertTrue(composition.add(secondDataSource))
        XCTAssertTrue(composition.add(thirdDataSource))

        XCTAssertEqual(composition.children as! [TestTableViewDataSource],
            [ firstDataSource, secondDataSource, thirdDataSource ])

        XCTAssertEqual(composition.updateMappings(), 3)

        // Test mappings

        XCTAssertEqual(composition.mapping(for: 0), composition.mapping(for: firstDataSource))
        XCTAssertEqual(composition.mapping(for: 1), composition.mapping(for: thirdDataSource))
        XCTAssertEqual(composition.mapping(for: 2), composition.mapping(for: thirdDataSource))

        // Test sections

        XCTAssertEqual(composition.sections(for: firstDataSource), IndexSet(0..<1))
        XCTAssertEqual(composition.sections(for: secondDataSource), IndexSet())
        XCTAssertEqual(composition.sections(for: thirdDataSource), IndexSet(1..<3))

        XCTAssertEqual(composition.firstSection(for: firstDataSource), 0)
        //XCTAssertNil(composition.firstSection(for: secondDataSource))
        XCTAssertEqual(composition.firstSection(for: thirdDataSource), 1)

        // local sections, expected global sections and data source
        let sectionsAndDataSource = [
            (IndexSet(0..<1), IndexSet(0..<1), firstDataSource),
            (IndexSet(0..<2), IndexSet(1..<3), thirdDataSource)
        ]

        for (localSections, expectedGlobalSections, dataSource) in sectionsAndDataSource {
            XCTAssertEqual(composition.globalSections(for: localSections, in: dataSource),
                expectedGlobalSections)
        }

        // Test index paths

        let globalIndexPaths = [
            IndexPath(row: 0, section: 0),
            IndexPath(row: 1, section: 0),
            IndexPath(row: 0, section: 1)
        ]

        let expectedLocalIndexPaths = [
            IndexPath(row: 0, section: 0),
            IndexPath(row: 1, section: 0),
            IndexPath(row: 0, section: 0)
        ]

        XCTAssertEqual(globalIndexPaths.map { composition.localIndexPath(for: $0)! },
            expectedLocalIndexPaths)

        // local index paths, expected global index paths and data source
        let indexPathsAndDataSource = [
            (
                [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)],
                [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)],
                firstDataSource
            ),
            (
                [IndexPath(row: 0, section: 0), IndexPath(row: 0, section: 1)],
                [IndexPath(row: 0, section: 1), IndexPath(row: 0, section: 2)],
                thirdDataSource
            )
        ]

        for (localIndexPaths, expectedGlobalIndexPaths, dataSource) in indexPathsAndDataSource {
            XCTAssertEqual(composition.globalIndexPaths(for: localIndexPaths, in: dataSource),
                expectedGlobalIndexPaths)
        }

        // Test local components

        let tableView = UITableView(frame: .zero, style: .plain)

        // index - global section, element: (dataSource, expected local section)
        let componentsPerGlobalSection = [
            (dataSource: firstDataSource, section: 0),
            (dataSource: thirdDataSource, section: 0),
            (dataSource: thirdDataSource, section: 1)
        ]

        for (globalSection, expected) in componentsPerGlobalSection.enumerated() {
            let components = composition.local(forSection: globalSection, in: tableView)
            XCTAssertEqual(components.dataSource as! TestTableViewDataSource, expected.dataSource)
            XCTAssertEqual(components.section, expected.section)
        }

        // data source, global index path, expected local index path
        let componentsAndGlobalIndexPaths = [
            (firstDataSource, IndexPath(row: 0, section: 0), IndexPath(row: 0, section: 0)),
            (firstDataSource, IndexPath(row: 1, section: 0), IndexPath(row: 1, section: 0)),
            (thirdDataSource, IndexPath(row: 0, section: 1), IndexPath(row: 0, section: 0)),
            (thirdDataSource, IndexPath(row: 0, section: 2), IndexPath(row: 0, section: 1))
        ]

        for (dataSource, globalIndexPath, expectedLocalIndexPath) in componentsAndGlobalIndexPaths {
            let components = composition.local(forIndexPath: globalIndexPath, in: tableView)
            XCTAssertEqual(components.dataSource as! TestTableViewDataSource, dataSource)
            XCTAssertEqual(components.indexPath, expectedLocalIndexPath)
        }

        // Test remove
        XCTAssertTrue(composition.remove(firstDataSource))
        XCTAssertEqual(composition.updateMappings(), 2)
        XCTAssertEqual(composition.sections(for: thirdDataSource), IndexSet(0..<2))
    }
}
