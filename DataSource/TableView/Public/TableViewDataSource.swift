//
//  TableViewDataSource.swift
//
//  Created by Dmytro Anokhin on 24/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


public class TableViewDataSource: ContentLoadingDataSource, TableViewDataSourceType {

    // MARK: - TableViewDataSourceType

    public var numberOfSections: Int {
        return 1
    }
    
    // MARK: - UITableViewDataSource
    
    // required
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Not implemented")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Not implemented")
    }
    
    // optional
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
}
