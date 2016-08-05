//
//  DataSourceTests.swift
//  DataSourceTests
//
//  Created by Dmytro Anokhin on 25/07/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class TestDataSource : TableViewDataSource, TableViewReusableViewsRegistering {

    let cellReuseIdentifier = "Identifier"

    override var numberOfSections: Int {
        return sections.count
    }
    
    var sections: [Int] {
        didSet {
            notify(update: TableViewUpdate.reloadData())
        }
    }
    
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
}


class DataSourceTests: XCTestCase {
    
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
    
    func testDataSource() {
    
        let dataSource = TestDataSource(sections: [ 1, 2 ])
        dataSource.registerReusableViews(with: tableView)

        tableView.dataSource = dataSource
        tableView.reloadData()
        
        XCTAssertEqual(tableView.numberOfSections, dataSource.sections.count)
        
        let visibleCells = tableView.visibleCells
        XCTAssertEqual(visibleCells.count, 3)
    }

    func testComposedDataSource() {
    
        let composedDataSource = TableViewComposedDataSource()
        
        let dataSource1 = TestDataSource(sections: [ 1, 2 ])
        composedDataSource.add(dataSource1)
        
        let dataSource2 = TestDataSource(sections: [ 3, 4 ])
        composedDataSource.add(dataSource2)
        
        composedDataSource.registerReusableViews(with: tableView)
        
        tableView.dataSource = composedDataSource
        tableView.reloadData()
        
        XCTAssertEqual(tableView.numberOfSections, 4)
        
        let visibleCells = tableView.visibleCells
        XCTAssertEqual(visibleCells.count, 10)
    }
    
    func testComposedDataSourceReloadData() {
    
        let composedDataSource = TableViewComposedDataSource()
        
        let dataSource1 = TestDataSource(sections: [ 1, 2 ])
        composedDataSource.add(dataSource1)
        
        let dataSource2 = TestDataSource(sections: [ 3, 4 ])
        composedDataSource.add(dataSource2)
        
        let reloadDataExpectation = expectation(description: "reloadData")
        
        let observer = TestObserver(tableView: tableView, performUpdateExpectation: reloadDataExpectation)
        composedDataSource.updateObserver = observer
        composedDataSource.contentLoadingObserver = observer
        
        composedDataSource.registerReusableViews(with: tableView)
        
        tableView.dataSource = composedDataSource
        tableView.reloadData()
        
        XCTAssertEqual(tableView.numberOfSections, 4)
        
        let visibleCells = tableView.visibleCells
        XCTAssertEqual(visibleCells.count, 10)
        
        dataSource2.sections = [ 1 ]
        waitForExpectations(timeout: 0.1) { error in
            let _ = observer // Observer must stay alive till this moment
            
            let visibleCells = self.tableView.visibleCells
            XCTAssertEqual(visibleCells.count, 4)
        }
    }
}
