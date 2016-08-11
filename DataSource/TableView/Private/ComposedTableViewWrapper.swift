//
//  ComposedTableViewWrapper.swift
//
//  Created by Dmytro Anokhin on 24/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


// TODO: Use Swift 3.0 syntax or move back to Objective-C

class ComposedTableViewWrapper: ComposedTableViewMappingWrapper {

    // MARK: - UITableView methods that work with sections or index paths

    var numberOfSections: Int {
        get {
            return mapping.sectionCount
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let globalSection = mapping.globalSection(for: section) else { return 0 }
        return tableView.numberOfRows(inSection: globalSection)
    }

    func rectForSection(_ section: Int) -> CGRect {
        guard let globalSection = mapping.globalSection(for: section) else { return CGRect.null }
        return tableView.rect(forSection: globalSection)
    }

    func rectForHeaderInSection(_ section: Int) -> CGRect {
    
        guard let globalSection = mapping.globalSection(for: section) else { return CGRect.null }
        return tableView.rectForHeader(inSection: globalSection)
    }
    
    func rectForFooterInSection(_ section: Int) -> CGRect {
    
        guard let globalSection = mapping.globalSection(for: section) else { return CGRect.null }
        return tableView.rectForFooter(inSection: globalSection)
    }

    func rectForRowAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        guard let globalIndexPath = mapping.globalIndexPath(for: indexPath) else { return CGRect.null }
        return tableView.rectForRow(at: globalIndexPath)
    }

    func indexPathForRowAtPoint(_ point: CGPoint) -> IndexPath? {
        guard let globalIndexPath = tableView.indexPathForRow(at: point),
              let localIndexPath = mapping.localIndexPath(for: globalIndexPath) else { return nil }
        
        return localIndexPath
    }

    func indexPathForCell(_ cell: UITableViewCell) -> IndexPath? {
        guard let globalIndexPath = tableView.indexPath(for: cell) else { return nil }
        return mapping.localIndexPath(for: globalIndexPath)
    }

    func indexPathsForRowsInRect(_ rect: CGRect) -> [IndexPath]? {
        guard let globalIndexPaths = tableView.indexPathsForRows(in: rect) else { return nil }
        return mapping.localIndexPaths(for: globalIndexPaths)
    }

    func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell? {
        guard let globalIndexPath = mapping.globalIndexPath(for: indexPath) else { return nil }
        return tableView.cellForRow(at: globalIndexPath)
    }

    var indexPathsForVisibleRows: [IndexPath]? {
        get {
            guard let globalIndexPaths = tableView.indexPathsForVisibleRows else { return nil }
            return mapping.localIndexPaths(for: globalIndexPaths)
        }
    }

    func headerViewForSection(_ section: Int) -> UITableViewHeaderFooterView? {
        guard let globalSection = mapping.globalSection(for: section) else { return nil }
        return tableView.headerView(forSection: globalSection)
    }
    
    func footerViewForSection(_ section: Int) -> UITableViewHeaderFooterView? {
        guard let globalSection = mapping.globalSection(for: section) else { return nil }
        return tableView.footerView(forSection: globalSection)
    }
    
    func scrollToRowAtIndexPath(_ indexPath: IndexPath, atScrollPosition scrollPosition: UITableViewScrollPosition, animated: Bool) {
        guard let globalIndexPath = mapping.globalIndexPath(for: indexPath) else { return }
        tableView.scrollToRow(at: globalIndexPath, at: scrollPosition, animated: animated)
    }
    
    func insertSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        let globalSections = mapping.globalSections(for: sections)
        tableView.insertSections(globalSections, with: animation)
    }

    func deleteSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        let globalSections = mapping.globalSections(for: sections)
        tableView.deleteSections(globalSections, with: animation)
    }

    func reloadSections(_ sections: IndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        let globalSections = mapping.globalSections(for: sections)
        tableView.reloadSections(globalSections, with: animation)
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        if  let globalSection = mapping.globalSection(for: section),
            let globalNewSection = mapping.globalSection(for: newSection)
        {
            tableView.moveSection(globalSection, toSection: globalNewSection)
        }
    }
    
    func insertRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        let globalIndexPaths = mapping.globalIndexPaths(for: indexPaths)
        tableView.insertRows(at: globalIndexPaths, with: animation)
    }

    func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        let globalIndexPaths = mapping.globalIndexPaths(for: indexPaths)
        tableView.deleteRows(at: globalIndexPaths, with: animation)
    }

    func reloadRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        let globalIndexPaths = mapping.globalIndexPaths(for: indexPaths)
        tableView.reloadRows(at: globalIndexPaths, with: animation)
    }

    func moveRowAtIndexPath(_ indexPath: IndexPath, toIndexPath newIndexPath: IndexPath) {
        guard let globalIndexPath = mapping.globalIndexPath(for: indexPath),
              let globalNewIndexPath = mapping.globalIndexPath(for: newIndexPath) else { return }
        
        tableView.moveRow(at: globalIndexPath, to: globalNewIndexPath)
    }
    
    var indexPathForSelectedRow: IndexPath? {
        get {
            guard let globalIndexPath = tableView.indexPathForSelectedRow else { return nil }
            return mapping.localIndexPath(for: globalIndexPath)
        }
    }
    
    var indexPathsForSelectedRows: [IndexPath]? {
        get {
            guard let globalIndexPaths = tableView.indexPathsForSelectedRows else { return nil }
            return mapping.localIndexPaths(for: globalIndexPaths)
        }
    }

    func selectRowAtIndexPath(_ indexPath: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        guard let localIndexPath = indexPath,
              let globalIndexPath = mapping.globalIndexPath(for: localIndexPath) else { return }
        tableView.selectRow(at: globalIndexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectRowAtIndexPath(_ indexPath: IndexPath, animated: Bool) {
        guard let globalIndexPath = mapping.globalIndexPath(for: indexPath) else { return }
        tableView.deselectRow(at: globalIndexPath, animated: animated)
    }

    //func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
    func dequeueReusableCellWithIdentifier(_ identifier: String, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let globalIndexPath = mapping.globalIndexPath(for: indexPath) else { fatalError("Index path not found in mapping") }
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: globalIndexPath)
    }
}
