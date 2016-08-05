//
//  Composable.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 04/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The Composable protocol defines interface for objects that may be combined together.
public protocol Composable {

    associatedtype Child

    @discardableResult
    func add(_ : Child) -> Bool
    
    @discardableResult
    func remove(_ : Child) -> Bool
    
    var children: [Child] { get }
}
