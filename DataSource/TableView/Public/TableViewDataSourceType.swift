//
//  TableViewDataSourceType.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The TableViewDataSourceType protocol defines specific methods for UITableView data sources
public protocol TableViewDataSourceType : UITableViewDataSource {//, UITableViewDelegate {

    /// The number of sections in this data source.
    var numberOfSections: Int { get }
}
