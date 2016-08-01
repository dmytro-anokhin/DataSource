//
//  ContentLoadingTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 22/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingTestDataSource : TableViewDataSource, TableViewReusableViewsRegistering {

    let cellReuseIdentifier = "Identifier"

    override var numberOfSections: Int {
        return sections.count
    }
    
    var sections: [Int]
    
    init(sections: [Int]) {
        self.sections = sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    }
    
    func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    override func loadContent() {
        contentLoadingController.loadContent { helper in
            DispatchQueue.global().async {
                guard helper.current else {
                    helper.ignore()
                    return
                }
                
                helper.updateWithContent { [weak self] in
                    guard let me = self else { return }
                    me.sections = [ 1 ]
                    let sections = IndexSet(integer: 0)
                    me.notify(update: TableViewUpdate.insertSections(sections))
                }
            }
        }
    }
}


class ContentLoadingTests: XCTestCase {
    
    var tableView: UITableView!
    
    override func setUp() {
        super.setUp()
        
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1000.0))
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    override func tearDown() {
        tableView = nil
        super.tearDown()
    }
    
    func testContentLoading() {
        
        let composedDataSource = TableViewComposedDataSource()
    
        let dataSource1 = ContentLoadingTestDataSource(sections: [])
        let dataSource2 = ContentLoadingTestDataSource(sections: [])
        
        composedDataSource.add(dataSource: dataSource1, animated: false)
        composedDataSource.add(dataSource: dataSource2, animated: false)
        
        let contentLoadedExpectation = expectation(description: "contentLoadedExpectation")
        
        let observer = TestObserver(tableView: tableView, willLoadContentExpectation: nil,
            didLoadContentExpectation: contentLoadedExpectation)
        composedDataSource.updateObserver = observer
        composedDataSource.contentLoadingObserver = observer
        
        composedDataSource.registerReusableViews(with: tableView)
        tableView.dataSource = composedDataSource
        tableView.reloadData()
        
        XCTAssertEqual(tableView.numberOfSections, 0)

        composedDataSource.loadContent()

        waitForExpectations(timeout: 0.1) { error in
            let _ = observer // Observer must stay alive till this moment
            
            let visibleCells = self.tableView.visibleCells
            XCTAssertEqual(visibleCells.count, 2)
        }
    }
}
