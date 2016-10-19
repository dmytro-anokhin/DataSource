//
//  TableViewDataSourceTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 24/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class EventsDataSource : TableViewDataSource, TableViewReusableViewsRegistering {
    
    let cellReuseIdentifier = "EventCell"
    
    struct Event {
        let title: String
    }
    
    var events: [Event] = []
    
    var fileName = "Events"
        
    func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    // MARK: - ContentLoading

    override func loadContent() {
        contentLoadingController.loadContent { coordinator in
            DispatchQueue.global().async {
                guard let path = Bundle(for: type(of: self)).path(forResource: self.fileName, ofType: "plist"),
                      let array = NSArray(contentsOfFile: path)
                else {
                    coordinator.done(withError: NSError(domain: "EventsDataSourceErrorDomain", code: 0))
                    return
                }
                
                let events: [Event] = array.flatMap { desc in
                    guard let desc = desc as? Dictionary<String, AnyObject>,
                          let title = desc["title"] as? String, !title.isEmpty
                    else {
                        return nil
                    }
                    
                    return Event(title: title)
                }
            
                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }
                
                coordinator.done { [weak self] in
                    guard let me = self else { return }
                    me.events = events
                    me.notifyUpdate(TableViewReloadDataUpdate())
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let event = events[indexPath.row]
        
        cell.textLabel?.text = event.title
        
        return cell
    }
}


class ShopsDataSource : TableViewDataSource, IndexPathIndexable, TableViewReusableViewsRegistering {
    
    let cellReuseIdentifier = "ShopCell"
    
    struct Shop {
        let name: String
    }
    
    var shops: [Shop] = []
    
    var fileName = "Shops"
    
    func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: - IndexPathIndexable
    
    func object(at indexPath: IndexPath) -> Any? {
        return indexPath.row < shops.count ? shops[indexPath.row] : nil
    }
    
    func indexPaths(for object: Any) -> [IndexPath] {
        
        guard let shop = object as? Shop else { return [] }
    
        var indexPaths: [IndexPath] = []
        
        for (index, element) in shops.enumerated() {
            if shop.name == element.name {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
        }
        
        return indexPaths
    }

    // MARK: - ContentLoading
    
    override func loadContent() {
        contentLoadingController.loadContent { coordinator in
            DispatchQueue.global().async {
                guard let path = Bundle(for: type(of: self)).path(forResource: self.fileName, ofType: "plist"),
                      let array = NSArray(contentsOfFile: path)
                else {
                    coordinator.done(withError: NSError(domain: "ShopsDataSourceErrorDomain", code: 0))
                    return
                }
                
                let shops: [Shop] = array.flatMap { desc in
                    guard let desc = desc as? Dictionary<String, AnyObject>,
                          let name = desc["name"] as? String, !name.isEmpty
                    else {
                        return nil
                    }
                    
                    return Shop(name: name)
                }
            
                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }
                
                coordinator.done { [weak self] in
                    guard let me = self else { return }
                    me.shops = shops
                    me.notifyUpdate(TableViewReloadDataUpdate())
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let shop = shops[indexPath.row]
        
        cell.textLabel?.text = shop.name
        
        return cell
    }
}


class ViewController : UpdateObserver, ContentLoadingObserver {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1000.0))
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        return tableView
    }()
    
    var dataSource: TableViewComposedDataSource? {
        didSet {
            dataSource?.registerReusableViews(with: tableView)
            dataSource?.updateObserver = self
            dataSource?.contentLoadingObserver = self
            
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }
    
    var willLoadContentExpectation: XCTestExpectation?
    var didLoadContentExpectation: XCTestExpectation?
    
    func perform(update: UpdateType, from sender: UpdateObservable) {
        update.perform(tableView)
    }

    func willLoadContent(_ sender: ContentLoadingObservable) {
        willLoadContentExpectation?.fulfill()
    }

    func didLoadContent(_ sender: ContentLoadingObservable, with error: Error?) {
        didLoadContentExpectation?.fulfill()
    }
}


class TableViewDataSourceTests: XCTestCase {

    var viewController: ViewController!
    
    override func setUp() {
        super.setUp()
        
        viewController = ViewController()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testContentLoadingInDataSource() {
    
        let rootDataSource = TableViewComposedDataSource()
        viewController.dataSource = rootDataSource
        
        let tableView = viewController.tableView
        
        // Root data source must be empty. Test if the table view reflects this.
        XCTAssertEqual(rootDataSource.numberOfSections, 0)
        XCTAssertEqual(tableView.numberOfSections, 0)
        
        let eventsDataSource = EventsDataSource()
        // Events data source must contain 1 section by default.
        XCTAssertEqual(eventsDataSource.numberOfSections, 1)
        eventsDataSource.registerReusableViews(with: tableView)
        
        let shopsDataSource = ShopsDataSource()
        shopsDataSource.registerReusableViews(with: tableView)
    
        rootDataSource.add(eventsDataSource)
        // Root data source must contain 1 section after adding events data source. Table view must reflect new number of sections.
        XCTAssertEqual(rootDataSource.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfSections, 1)
        // Data source is empty. Test if the table view reflects this.
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
        
        rootDataSource.add(shopsDataSource)
        // Root data source must contain 2 sections after adding shops data source. Table view must reflect new number of sections.
        XCTAssertEqual(rootDataSource.numberOfSections, 2)
        XCTAssertEqual(tableView.numberOfSections, 2)
        // Data source is still empty. Test if the table view reflects this.
        XCTAssertEqual(tableView.numberOfRows(inSection: 1), 0)
        
        // Test if events and shops data sources are in composition.
        XCTAssertEqual(rootDataSource.children[0] as! TableViewDataSource, eventsDataSource)
        XCTAssertEqual(rootDataSource.children[1] as! TableViewDataSource, shopsDataSource)
        
        // MARK: Content loading test.
        
        // Make some expectations for will and did load.
        viewController.willLoadContentExpectation = expectation(description: "Will load content")
        viewController.didLoadContentExpectation = expectation(description: "Did load content")
        
        // Test initial loading state.
        XCTAssertEqual(rootDataSource.loadingState, .initial)
        
        // Begin loading.
        rootDataSource.loadContent()
        
        // Test loading content loading state.
        XCTAssertEqual(rootDataSource.loadingState, .loadingContent)
        
        // Waiting for will and did load content expectations
        waitForExpectations(timeout: 0.5) { _ in
            // Test content loaded loading state.
            XCTAssertEqual(rootDataSource.loadingState, ContentLoadingState.contentLoaded)
        
            // Test if content was loaded succesfully.
            XCTAssert(eventsDataSource.events.count > 0)
            XCTAssert(shopsDataSource.shops.count > 0)
            
            // Test if we can access object by index path
            let event = rootDataSource.object(at: IndexPath(row: 1, section: 0))
            XCTAssertNil(event) // Events data source doesn't implements IndexPathIndexable protocol
            
            let shop = rootDataSource.object(at: IndexPath(row: 1, section: 1))
            XCTAssertNotNil(shop) // Shops data source implements IndexPathIndexable protocol
            
            let indexPaths = rootDataSource.indexPaths(for: shop)
            XCTAssertEqual(indexPaths, [ IndexPath(row: 1, section: 1) ])
            
            // Test if table view reflects changes.
            XCTAssertEqual(tableView.numberOfRows(inSection: 0), eventsDataSource.events.count)
            XCTAssertEqual(tableView.numberOfRows(inSection: 1), shopsDataSource.shops.count)
            
            // Test if data sources content are reflected in visible cells.
            XCTAssertEqual(eventsDataSource.events.map { $0.title } + shopsDataSource.shops.map { $0.name },
                tableView.visibleCells.flatMap { $0.textLabel?.text })
            
            // MARK: Content reloading test.
            
            // First, reset content.
            eventsDataSource.events = []
            shopsDataSource.shops = []
            
            // Setup new expectations.
            self.viewController.willLoadContentExpectation = self.expectation(description: "Will reload content")
            self.viewController.didLoadContentExpectation = self.expectation(description: "Did reload content")
            
            // Begin reloading.
            rootDataSource.loadContent()
            
            // loadingState must be loading content.
            XCTAssertEqual(rootDataSource.loadingState, .loadingContent)
            
            // Waiting for will and did reload content expectations
            self.waitForExpectations(timeout: 0.5) { _ in
                // Test content loaded loading state.
                XCTAssertEqual(rootDataSource.loadingState, .contentLoaded)
            
                // Test if content was reloaded succesfully.
                XCTAssert(eventsDataSource.events.count > 0)
                XCTAssert(shopsDataSource.shops.count > 0)
                
                // Test if table view reflects changes.
                XCTAssertEqual(tableView.numberOfRows(inSection: 0), eventsDataSource.events.count)
                XCTAssertEqual(tableView.numberOfRows(inSection: 1), shopsDataSource.shops.count)
                
                // Test if data sources content are reflected in visible cells.
                XCTAssertEqual(eventsDataSource.events.map { $0.title } + shopsDataSource.shops.map { $0.name },
                    tableView.visibleCells.flatMap { $0.textLabel?.text })
                
                // MARK: Content loading error test
                
                // Setup new expectations.
                self.viewController.willLoadContentExpectation = self.expectation(description: "Will reload content with error")
                self.viewController.didLoadContentExpectation = self.expectation(description: "Did reload content with error")
                
                eventsDataSource.fileName = "No file"
                shopsDataSource.fileName = "No file"
                
                // Begin reloading.
                rootDataSource.loadContent()
                
                // loadingState must be loading content.
                XCTAssertEqual(rootDataSource.loadingState, .loadingContent)
                
                // Waiting for will and did reload content expectations
                self.waitForExpectations(timeout: 0.5) { _ in
                    // Test error loading state.
                    XCTAssertEqual(rootDataSource.loadingState, .error)
                }
            }
        }
    }
}
