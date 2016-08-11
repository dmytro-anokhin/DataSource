//
//  TableViewReusableViewsRegistering.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 29/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol TableViewReusableViewsRegistering {
    
    func registerReusableViews(with tableView: UITableView)
}


public extension TableViewReusableViewsRegistering where Self: Composable, Self.Child == TableViewDataSourceType {
    
    func registerReusableViews(with tableView: UITableView) {
        for dataSource in children {
            (dataSource as? TableViewReusableViewsRegistering)?.registerReusableViews(with: tableView)
        }
    }
}
