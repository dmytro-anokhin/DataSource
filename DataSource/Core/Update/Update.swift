//
//  Update.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 04/04/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol UpdateType {

    func perform(_ view: UIView)
}


public enum StructureChangeType {

    case insert

    case delete

    case reload

    case move
}


public protocol StructureUpdateType : UpdateType {

    associatedtype Elements

    var changeType: StructureChangeType { get }

    var elements: Elements? { get }

    var newElements: Elements? { get }
}


public protocol UpdateAnimating {

    var animated: Bool { get }
}


public protocol TableViewRowAnimating : UpdateAnimating {

    var animation: UITableViewRowAnimation { get }
}


extension TableViewRowAnimating {

    public var animated: Bool { return animation != .none }
}


// MARK: - Implementation


public struct ArbitraryUpdate : UpdateType {

    private let closure: () -> Void

    public init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    public func perform(_ view: UIView) {
        closure()
    }
}


public struct TableViewReloadDataUpdate : UpdateType {

    public init() {
    }

    public func perform(_ view: UIView) {
        (view as? UITableView)?.reloadData()
    }
}


public struct TableViewRowsUpdate : StructureUpdateType, TableViewRowAnimating {

    public init(insert rows: Elements, with animation: UITableViewRowAnimation = .none) {
        self.changeType = .insert
        self.elements = nil
        self.newElements = rows
        self.animation = animation
    }

    public init(delete rows: Elements, with animation: UITableViewRowAnimation = .none) {
        self.changeType = .delete
        self.elements = rows
        self.newElements = nil
        self.animation = animation
    }

    public init(reload rows: Elements, with animation: UITableViewRowAnimation = .none) {
        self.changeType = .reload
        self.elements = rows
        self.newElements = nil
        self.animation = animation
    }

    public init(move rows: Elements, to newRows: Elements) {
        self.changeType = .move
        self.elements = rows
        self.newElements = newRows
        self.animation = .none
    }

    public init?(changeType: StructureChangeType, indexPaths: Elements? = nil, newIndexPaths: Elements? = nil,
        animation: UITableViewRowAnimation = .none)
    {
        switch changeType {
            case .insert:
                if nil == newIndexPaths {
                    assertionFailure("Incorrect insert rows update")
                    return nil
                }
            case .delete:
                if nil == indexPaths {
                    assertionFailure("Incorrect delete rows update")
                    return nil
                }
            case .reload:
                if nil == indexPaths {
                    assertionFailure("Incorrect reload rows update")
                    return nil
                }
            case .move:
                if nil == indexPaths || nil == newIndexPaths {
                    assertionFailure("Incorrect move rows update")
                    return nil
                }
        }

        self.changeType = changeType
        self.elements = indexPaths
        self.newElements = newIndexPaths
        self.animation = animation
    }

    // MARK: - StructureUpdateType

    public typealias Elements = [IndexPath]

    public let changeType: StructureChangeType

    public let elements: Elements?

    public let newElements: Elements?

    // MARK: - TableViewRowAnimating

    public let animation: UITableViewRowAnimation

    // MARK: - UpdateType

    public func perform(_ view: UIView) {

        guard let tableView = view as? UITableView else { return }

        switch changeType {

            case .insert:
                guard let newIndexPaths = newElements else { return }
                tableView.insertRows(at: newIndexPaths, with: animation)

            case .delete:
                guard let indexPaths = elements else { return }
                tableView.deleteRows(at: indexPaths, with: animation)

            case .reload:
                guard let indexPaths = elements else { return }
                tableView.reloadRows(at: indexPaths, with: animation)

            case .move:
                guard let indexPath = elements?.first, let newIndexPath = newElements?.first else { return }
                tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
}


public struct TableViewSectionsUpdate : StructureUpdateType, TableViewRowAnimating {

    public init(insert sections: Elements, with animation: UITableViewRowAnimation = .none) {
        self.changeType = .insert
        self.elements = nil
        self.newElements = sections
        self.animation = animation
    }

    public init(delete sections: Elements, with animation: UITableViewRowAnimation = .none) {
        self.changeType = .delete
        self.elements = sections
        self.newElements = nil
        self.animation = animation
    }

    public init(reload sections: Elements, with animation: UITableViewRowAnimation = .none) {
        self.changeType = .reload
        self.elements = sections
        self.newElements = nil
        self.animation = animation
    }

    public init(move sections: Elements, to newSections: Elements) {
        self.changeType = .move
        self.elements = sections
        self.newElements = newSections
        self.animation = .none
    }

    public init?(changeType: StructureChangeType, sections: Elements? = nil, newSections: Elements? = nil,
        animation: UITableViewRowAnimation = .none)
    {
        switch changeType {
            case .insert:
                if nil == newSections {
                    assertionFailure("Incorrect insert sections update")
                    return nil
                }
            case .delete:
                if nil == sections {
                    assertionFailure("Incorrect delete sections update")
                    return nil
                }
            case .reload:
                if nil == sections {
                    assertionFailure("Incorrect reload sections update")
                    return nil
                }
            case .move:
                if nil == sections || nil == newSections {
                    assertionFailure("Incorrect move sections update")
                    return nil
                }
        }

        self.changeType = changeType
        self.elements = sections
        self.newElements = newSections
        self.animation = animation
    }

    // MARK: - StructureUpdateType

    public typealias Elements = IndexSet

    public let changeType: StructureChangeType

    public let elements: Elements?

    public let newElements: Elements?

    // MARK: - TableViewRowAnimating

    public let animation: UITableViewRowAnimation

    // MARK: - UpdateType

    public func perform(_ view: UIView) {

        guard let tableView = view as? UITableView else { return }

        switch changeType {

            case .insert:
                guard let newSections = newElements else { return }
                tableView.insertSections(newSections, with: animation)

            case .delete:
                guard let sections = elements else { return }
                tableView.deleteSections(sections, with: animation)

            case .reload:
                guard let sections = elements else { return }
                tableView.reloadSections(sections, with: animation)

            case .move:
                guard let section = elements?.first, let newSection = newElements?.first else { return }
                tableView.moveSection(section, toSection: newSection)
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public struct BatchUpdate : UpdateType, UpdateAnimating {

    public let updates: [UpdateType]

    init(updates: [UpdateType]) {
        self.updates = updates
    }

    // MARK: - UpdateType

    public func perform(_ view: UIView) {

        if animated {
            (view as? UITableView)?.beginUpdates()
        }

        for update in updates {
            update.perform(view)
        }

        if animated {
            (view as? UITableView)?.endUpdates()
        }
    }

    // MARK: - AnimatedUpdate

    public var animated: Bool {

        for update in updates {
            guard let update = update as? UpdateAnimating else { continue }

            if update.animated {
                return true
            }
        }

        return false
    }
}
