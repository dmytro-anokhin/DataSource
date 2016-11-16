//
//  UpdateTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class UpdateTests: XCTestCase {

    func testTableViewRowAnimating() {

        struct Animator: TableViewRowAnimating {
            let animation: UITableViewRowAnimation
        }

        XCTAssertFalse(Animator(animation: .none).animated)
        XCTAssertTrue(Animator(animation: .automatic).animated)
    }

    func testArbitraryUpdate() {

        let updateExpectation = expectation(description: "Update expectation")
        let update = ArbitraryUpdate { _ in
            updateExpectation.fulfill()
        }

        update.perform(UIView())

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testBatchUpdate() {

        class AnimatedUpdate: UpdateType, UpdateAnimating {

            var animated: Bool { return true }

            func perform(_ view: UIView) {
            }
        }

        let firstExpectation = expectation(description: "First expectation")
        let firstUpdate = ArbitraryUpdate { _ in
            firstExpectation.fulfill()
        }

        let secondExpectation = expectation(description: "Second expectation")
        let secondUpdate = ArbitraryUpdate { _ in
            secondExpectation.fulfill()
        }

        var batchUpdate = BatchUpdate(updates: [ firstUpdate, secondUpdate ])
        XCTAssertFalse(batchUpdate.animated)

        batchUpdate = BatchUpdate(updates: [ firstUpdate, secondUpdate, AnimatedUpdate() ])
        XCTAssertTrue(batchUpdate.animated)

        batchUpdate.perform(UIView())

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}


class TableViewUpdateTests: XCTestCase {

    var tableView: TestTableView!
    var genericExpectation: XCTestExpectation?

    override func setUp() {
        super.setUp()

        tableView = TestTableView()
        genericExpectation = expectation(description: "Generic expectation")
    }

    func testReloadData() {

        tableView.didReloadData = { _ in
            self.genericExpectation?.fulfill()
        }

        let update = TableViewReloadDataUpdate()
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testInsertRows() {

        let indexPathsToInsert = [ IndexPath(row: 0, section: 1) ]
        let animationToPerform: UITableViewRowAnimation = .automatic

        tableView.didInsertRows = { tableView, indexPaths, animation in
            XCTAssertEqual(indexPathsToInsert, indexPaths)
            XCTAssertEqual(animationToPerform, animation)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewRowsUpdate(insert: indexPathsToInsert, with: animationToPerform)
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testDeleteRows() {

        let indexPathsToDelete = [ IndexPath(row: 0, section: 1) ]
        let animationToPerform: UITableViewRowAnimation = .automatic

        tableView.didDeleteRows = { tableView, indexPaths, animation in
            XCTAssertEqual(indexPathsToDelete, indexPaths)
            XCTAssertEqual(animationToPerform, animation)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewRowsUpdate(delete: indexPathsToDelete, with: animationToPerform)
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testReloadRows() {

        let indexPathsToReload = [ IndexPath(row: 0, section: 1) ]
        let animationToPerform: UITableViewRowAnimation = .automatic

        tableView.didReloadRows = { tableView, indexPaths, animation in
            XCTAssertEqual(indexPathsToReload, indexPaths)
            XCTAssertEqual(animationToPerform, animation)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewRowsUpdate(reload: indexPathsToReload, with: animationToPerform)
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testMoveRow() {

        let indexPathFrom = IndexPath(row: 0, section: 1)
        let indexPathTo = IndexPath(row: 2, section: 3)

        tableView.didMoveRow = { tableView, indexPath, newIndexPath in
            XCTAssertEqual(indexPathFrom, indexPath)
            XCTAssertEqual(indexPathTo, newIndexPath)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewRowsUpdate(move: [ indexPathFrom ], to: [ indexPathTo ])
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testInsertSections() {

        let sectionsToInsert: IndexSet = [0]
        let animationToPerform: UITableViewRowAnimation = .automatic

        tableView.didInsertSections = { tableView, sections, animation in
            XCTAssertEqual(sectionsToInsert, sections)
            XCTAssertEqual(animationToPerform, animation)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewSectionsUpdate(insert: sectionsToInsert, with: animationToPerform)
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testDeleteSections() {

        let sectionsToDelete: IndexSet = [0]
        let animationToPerform: UITableViewRowAnimation = .automatic

        tableView.didDeleteSections = { tableView, sections, animation in
            XCTAssertEqual(sectionsToDelete, sections)
            XCTAssertEqual(animationToPerform, animation)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewSectionsUpdate(delete: sectionsToDelete, with: animationToPerform)
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testReloadSections() {

        let sectionsToReload: IndexSet = [0]
        let animationToPerform: UITableViewRowAnimation = .automatic

        tableView.didReloadSections = { tableView, sections, animation in
            XCTAssertEqual(sectionsToReload, sections)
            XCTAssertEqual(animationToPerform, animation)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewSectionsUpdate(reload: sectionsToReload, with: animationToPerform)
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testMoveSection() {

        let sectionFrom = 0
        let sectionTo = 1

        tableView.didMoveSection = { tableView, section, newSection in
            XCTAssertEqual(sectionFrom, section)
            XCTAssertEqual(sectionTo, newSection)

            self.genericExpectation?.fulfill()
        }

        let update = TableViewSectionsUpdate(move: IndexSet([sectionFrom]), to: IndexSet([sectionTo]))
        update.perform(tableView)

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
