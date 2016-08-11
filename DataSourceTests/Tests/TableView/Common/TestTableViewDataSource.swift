//
//  TestTableViewDataSource.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 06/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

@testable import DataSource


/// The TestTableViewDataSource is a data source that provides basic features for test purposes.
class TestTableViewDataSource : TableViewDataSource, TableViewReusableViewsRegistering {

    let cellReuseIdentifier = NSStringFromClass(UITableViewCell.self)

    /// The sections is an array of numbers representing number of rows per section
    var sections: [Int]
    
    required init(sections: [Int]) {
        self.sections = sections
    }

    override var numberOfSections: Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = "(\(indexPath.section), \(indexPath.row))"
        
        return cell
    }
    
    func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
}
