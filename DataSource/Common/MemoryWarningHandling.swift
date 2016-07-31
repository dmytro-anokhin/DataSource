//
//  MemoryWarningHandling.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 19/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol MemoryWarningHandling {
    
    func didReceiveMemoryWarning()
}


public extension MemoryWarningHandling {

    func didReceiveMemoryWarning() {
    }
}


public extension MemoryWarningHandling where Self: ComposedDataSourceType {

    func didReceiveMemoryWarning() {
        for dataSource in dataSources {
            (dataSource as? MemoryWarningHandling)?.didReceiveMemoryWarning()
        }
    }
}
