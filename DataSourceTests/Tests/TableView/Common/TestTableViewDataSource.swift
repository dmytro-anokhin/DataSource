//
//  TestTableViewDataSource.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 16/11/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import DataSource


class TestTableViewDataSource: NSObject, TableViewDataSourceType, UITableViewDelegate {

    typealias NumberOfRows = Int

    /// Array of sections represented by number of rows
    var sections: [NumberOfRows] = []

    var numberOfSections: Int {
        get {
            return sections.count
        }

        set {
            var sections: [Int] = []
            for _ in 0..<newValue {
                sections.append(0)
            }

            self.sections = sections
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseIdentifier = "TestTableViewDataSourceCell"

        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)

        if nil == cell {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let reuseIdentifier = "TestTableViewDataSourceHeader"

        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)

        if nil == view {
            view = UITableViewHeaderFooterView(reuseIdentifier: reuseIdentifier)
        }

        view?.tag = section

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let reuseIdentifier = "TestTableViewDataSourceFooter"

        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)

        if nil == view {
            view = UITableViewHeaderFooterView(reuseIdentifier: reuseIdentifier)
        }

        view?.tag = section

        return view
    }
}
