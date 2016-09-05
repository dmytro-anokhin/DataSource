//
//  TableViewUpdate.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 24/02/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


// TODO: Rename in insert(sections:) insert(rows:)

public class TableViewUpdate: Update {

    // MARK: - Factory functions
    
    public class func scrollToTop(_ animated: Bool = true) -> TableViewUpdate {
        return TableViewScrollToTopUpdate(animated: animated)
    }

    public class func reloadData() -> TableViewUpdate {
        return TableViewReloadDataUpdate()
    }
    
    public class func insertRows(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .none) -> TableViewUpdate {
        return TableViewRowsUpdate(type: .insert, animation: animation, indexPaths: nil, newIndexPaths: indexPaths, sections: nil, newSections: nil)
    }
    
    public class func deleteRows(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .none) -> TableViewUpdate {
        return TableViewRowsUpdate(type: .delete, animation: animation, indexPaths: indexPaths, newIndexPaths: nil, sections: nil, newSections: nil)
    }
    
    public class func reloadRows(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .none) -> TableViewUpdate {
        return TableViewRowsUpdate(type: .reload, animation: animation, indexPaths: indexPaths, newIndexPaths: nil, sections: nil, newSections: nil)
    }
    
    // TODO: moveRow
    
    public class func insertSections(_ sections: IndexSet, animation: UITableViewRowAnimation = .none) -> TableViewUpdate {
        return TableViewSectionsUpdate(type: .insert, animation: animation, indexPaths: nil, newIndexPaths: nil, sections: nil, newSections: sections)
    }
    
    public class func deleteSections(_ sections: IndexSet, animation: UITableViewRowAnimation = .none) -> TableViewUpdate {
        return TableViewSectionsUpdate(type: .delete, animation: animation, indexPaths: nil, newIndexPaths: nil, sections: sections, newSections: nil)
    }
    
    public class func reloadSections(_ sections: IndexSet, animation: UITableViewRowAnimation = .none) -> TableViewUpdate {
        return TableViewSectionsUpdate(type: .reload, animation: animation, indexPaths: nil, newIndexPaths: nil, sections: sections, newSections: nil)
    }
    
    // TODO: moveSection

}


public class TableViewScrollToTopUpdate: TableViewUpdate {
    
    public let animated: Bool
    
    public init(animated: Bool = true) {
        self.animated = animated
    }
    
    public final override func perform(_ view: UIView?) {
        
        guard let tableView = view as? UITableView else { return }
    
        let indexPath = IndexPath(row: 0, section: 0)
        guard indexPath.section < tableView.numberOfSections
            && indexPath.row < tableView.numberOfRows(inSection: 0) else { return }
    
        tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
}


public class TableViewReloadDataUpdate: TableViewUpdate {
    
    public final override func perform(_ view: UIView?) {
        guard let tableView = view as? UITableView else { return }
        tableView.reloadData()
    }
}


public class TableViewStructureUpdate: TableViewUpdate, AnimatedUpdate {
    
    public let type: UpdateType
    
    public let animation: UITableViewRowAnimation
    
    public var animated: Bool { return animation != .none }
    
    public required init(type: UpdateType, animation: UITableViewRowAnimation = .none,
        indexPaths: [IndexPath]? = nil, newIndexPaths: [IndexPath]? = nil,
        sections: IndexSet? = nil, newSections: IndexSet? = nil)
    {
        self.type = type
        self.animation = animation
        
        self.indexPaths = indexPaths
        self.newIndexPaths = newIndexPaths
        self.sections = sections
        self.newSections = newSections
    }
    
    public let indexPaths: [IndexPath]?
    
    public let newIndexPaths: [IndexPath]?
    
    public let sections: IndexSet?
    
    public let newSections: IndexSet?
}


public class TableViewSectionsUpdate: TableViewStructureUpdate {
    
    public final override func perform(_ view: UIView?) {
    
        guard let tableView = view as? UITableView else { return }
    
        switch type {
            case .insert:
                if let newSections = newSections {
                    tableView.insertSections(newSections, with: animation)
                }
            case .delete:
                if let sections = sections {
                    tableView.deleteSections(sections, with: animation)
                }
            case .reload:
                if let sections = sections {
                    tableView.reloadSections(sections, with: animation)
                }
            case .move:
                if  let section = sections?.first,
                    let newSection = newSections?.first
                {
                    tableView.moveSection(section, toSection: newSection)
                }
        }
    }
}

public class TableViewRowsUpdate: TableViewStructureUpdate {

    public final override func perform(_ view: UIView?) {
    
        guard let tableView = view as? UITableView else { return }
        
        switch type {
            case .insert:
                if let newIndexPaths = newIndexPaths {
                    tableView.insertRows(at: newIndexPaths, with: animation)
                }
            case .delete:
                if let indexPaths = indexPaths {
                    tableView.deleteRows(at: indexPaths, with: animation)
                }
            case .reload:
                if let indexPaths = indexPaths {
                    tableView.reloadRows(at: indexPaths, with: animation)
                }
            case .move:
                if  let indexPath = indexPaths?.first,
                    let newIndexPath = newIndexPaths?.first
                {
                    tableView.moveRow(at: indexPath, to: newIndexPath)
                }
        }
    }
}


public class TableViewBatchUpdate: BatchUpdate {

    public final override func perform(_ view: UIView?) {
    
        guard let tableView = view as? UITableView else { return }
    
        if animated {
            tableView.beginUpdates()
            internalPerform(tableView)
            tableView.endUpdates()
            
            return
        }
        
        internalPerform(tableView)
    }
    
    private func internalPerform(_ tableView: UITableView) {
        for update in updates {
            update.perform(tableView)
        }
    }
}
