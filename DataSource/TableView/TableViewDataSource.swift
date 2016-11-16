//
//  TableViewDataSource.swift
//
//  Created by Dmytro Anokhin on 24/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


open class TableViewDataSource : ContentLoadingDataSource, TableViewDataSourceType {

    // MARK: - TableViewDataSourceType

    open var numberOfSections: Int {
        return 1
    }
    
    // MARK: - UITableViewDataSource
    
    // required
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Not implemented")
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Not implemented")
    }

    // optional
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
}
