//
//  TableViewDataSourceType.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The TableViewDataSourceType protocol defines specific methods for UITableView data sources
public protocol TableViewDataSourceType : UITableViewDataSource {

    /// The number of sections in this data source.
    var numberOfSections: Int { get }
    
    /// Performs necessary actions to set up this data source with provided tableview.
    func configure(with tableView: UITableView)
}


public extension TableViewDataSourceType {
    
    func configure(with tableView: UITableView) {
        (self as? TableViewReusableViewsRegistering)?.registerReusableViews(with: tableView)
        tableView.dataSource = self
    }
}
