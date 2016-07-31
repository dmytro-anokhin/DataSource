//
//  DataSourceType.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

// TODO: Index path is not even required.

/// The DataSourceType is a base definition of data source interface
public protocol DataSourceType {

    /// Returns object at specific index path.
    func object(at indexPath: IndexPath) -> Any?
    
    /// Find the index paths of the specified object in the data source. An object may appear more than once in a given data source.
    func indexPaths(for object: Any) -> [IndexPath]
}
