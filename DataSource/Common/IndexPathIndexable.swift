//
//  IndexPathIndexable.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 01/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import Foundation


public protocol IndexPathIndexable {

    /// Returns object at specific index path.
    func object(at indexPath: IndexPath) -> Any?
    
    /// Find the index paths of the specified object in the data source. An object may appear more than once in a given data source.
    func indexPaths(for object: Any) -> [IndexPath]
}
