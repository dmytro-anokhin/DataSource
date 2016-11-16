//
//  TableViewProxyTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 02/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class TableViewProxyTests: XCTestCase {

    func testProxy() {

        let sections = [4, 0, 5]

        let tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0),
            style: .grouped)

        let dataSource = TestTableViewDataSource()
        dataSource.sections = sections

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        let mapping = TableViewSectionMapping(dataSource: dataSource)
        XCTAssertEqual(mapping.updateMappings(startingWith: 0), sections.count)

        let proxy = TableViewProxy.proxy(with: tableView, mapping: mapping)

        XCTAssertEqual(proxy.frame, tableView.frame)
        XCTAssertEqual(proxy.style, tableView.style)

        XCTAssertEqual(proxy.numberOfSections, sections.count)

        for section in 0..<sections.count {
            XCTAssertEqual(proxy.numberOfRows(inSection: section), tableView.numberOfRows(inSection: section))
            XCTAssertEqual(proxy.rect(forSection: section), tableView.rect(forSection: section))
            XCTAssertEqual(proxy.rectForHeader(inSection: section), tableView.rectForHeader(inSection: section))
            XCTAssertEqual(proxy.rectForFooter(inSection: section), tableView.rectForFooter(inSection: section))
        }

        let testPoint = CGPoint(x: tableView.frame.midX, y: tableView.frame.midY)
        XCTAssertEqual(proxy.indexPathForRow(at: testPoint), tableView.indexPathForRow(at: testPoint))

        let testRect = tableView.frame
        XCTAssertEqual(proxy.indexPathsForRows(in: testRect)!, tableView.indexPathsForRows(in: testRect)!)

        XCTAssertEqual(proxy.indexPathsForVisibleRows!, tableView.indexPathsForVisibleRows!)

        for (section, numberOfRows) in sections.enumerated() {

            let proxyHeaderView = proxy.headerView(forSection: section)
            let headerView = tableView.headerView(forSection: section)

            XCTAssertEqual(proxyHeaderView?.tag, headerView?.tag)

            let proxyFooterView = proxy.footerView(forSection: section)
            let footerView = tableView.footerView(forSection: section)

            XCTAssertEqual(proxyFooterView?.tag, footerView?.tag)

            for row in 0..<numberOfRows {
                let indexPath = IndexPath(row: row, section: section)

                XCTAssertEqual(proxy.rectForRow(at: indexPath), tableView.rectForRow(at: indexPath))

                let proxyCell = proxy.cellForRow(at: indexPath)
                let cell = tableView.cellForRow(at: indexPath)

                if let proxyCell = proxyCell, let cell = cell {
                    XCTAssertEqual(proxy.indexPath(for: proxyCell), tableView.indexPath(for: cell))
                }
                else {
                    XCTAssertNil(proxyCell)
                    XCTAssertNil(cell)
                }
            }
        }

    // TODO:
/*
    func scrollToRowAtIndexPath(_ indexPath: IndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool)
    func insertSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation)
    func deleteSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation)
    func reloadSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation)
    func moveSection(_ section: Int, toSection newSection: Int)
    func insertRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation)
    func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation)
    func reloadRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation)
    func moveRowAtIndexPath(_ indexPath: IndexPath, toIndexPath newIndexPath: IndexPath)
    var indexPathForSelectedRow: IndexPath?
    var indexPathsForSelectedRows: [IndexPath]?
    func selectRowAtIndexPath(_ indexPath: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition)
    func deselectRowAtIndexPath(_ indexPath: IndexPath, animated: Bool)
    func dequeueReusableCellWithIdentifier(_ identifier: String, forIndexPath indexPath: IndexPath) -> UITableViewCell
*/

    }
}
