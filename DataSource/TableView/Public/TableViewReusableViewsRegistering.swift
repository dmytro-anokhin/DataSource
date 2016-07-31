//
//  TableViewReusableViewsRegistering.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 29/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import UIKit


public protocol TableViewReusableViewsRegistering {
    
    func registerReusableViews(with tableView: UITableView)
}


public extension TableViewReusableViewsRegistering where Self: ComposedDataSourceType, Self.ChildDataSource == TableViewDataSourceType {
    
    func registerReusableViews(with tableView: UITableView) {
        for dataSource in dataSources {
            (dataSource as? TableViewReusableViewsRegistering)?.registerReusableViews(with: tableView)
        }
    }
}
