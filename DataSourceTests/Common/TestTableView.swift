//
//  TestTableView.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/10/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import UIKit


class TestTableView: UITableView {

    var didReloadData: ((TestTableView) -> Void)?

    typealias UpdatesClosure = (TestTableView) -> Void

    var willBeginUpdates: UpdatesClosure?
    var didEndUpdates: UpdatesClosure?

    typealias SectionsClosure = (TestTableView, IndexSet, UITableViewRowAnimation) -> Void

    var didInsertSections: SectionsClosure?
    var didDeleteSections: SectionsClosure?
    var didReloadSections: SectionsClosure?
    var didMoveSection: ((TestTableView, Int, Int) -> Void)?

    typealias RowsClosure = (TestTableView, [IndexPath], UITableViewRowAnimation) -> Void

    var didInsertRows: RowsClosure?
    var didDeleteRows: RowsClosure?
    var didReloadRows: RowsClosure?
    var didMoveRow: ((TestTableView, IndexPath, IndexPath) -> Void)?

    override func reloadData() {
        didReloadData?(self)
    }

    override func beginUpdates() {
        willBeginUpdates?(self)
    }

    override func endUpdates() {
        didEndUpdates?(self)
    }

    override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        didInsertSections?(self, sections, animation)
    }

    override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        didDeleteSections?(self, sections, animation)
    }

    override func reloadSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        didReloadSections?(self, sections, animation)
    }

    override func moveSection(_ section: Int, toSection newSection: Int) {
        didMoveSection?(self, section, newSection)
    }
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        didInsertRows?(self, indexPaths, animation)
    }

    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        didDeleteRows?(self, indexPaths, animation)
    }

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        didReloadRows?(self, indexPaths, animation)
    }

    override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        didMoveRow?(self, indexPath, newIndexPath)
    }
}
