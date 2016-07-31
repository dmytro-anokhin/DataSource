//
//  ComposedDataSourceType.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The ComposedDataSourceType is a base definition of data source composition interface
public protocol ComposedDataSourceType {

    associatedtype ChildDataSource

    @discardableResult
    func add(dataSource: ChildDataSource, animated: Bool) -> Bool
    
    @discardableResult
    func remove(dataSource: ChildDataSource, animated: Bool) -> Bool
    
    var dataSources: [ChildDataSource] { get }
}
