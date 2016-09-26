//: Playground - noun: a place where people can play

/*
    Goal of this playground is to test out various architecture decisions for Update component
*/

import UIKit
//import MapKit


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


public protocol TableViewRowAnimating {

    var animation: UITableViewRowAnimation { get }
}


extension UpdateAnimating where Self: TableViewRowAnimating {

    public var animated: Bool { return animation != .none }
}


// MARK: - Implementation


public struct ArbitraryUpdate : UpdateType {

    let closure: () -> Void

    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    public func perform(_ view: UIView) {
        closure()
    }
}


public struct TableViewReloadDataUpdate : UpdateType {

    public func perform(_ view: UIView) {
        (view as? UITableView)?.reloadData()
    }
}


public struct TableViewRowsUpdate : StructureUpdateType, TableViewRowAnimating {

    init(changeType: StructureChangeType, indexPaths: Elements? = nil, newIndexPaths: Elements? = nil,
        animation: UITableViewRowAnimation = .none)
    {
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

    init(changeType: StructureChangeType, sections: IndexSet? = nil, newSections: Elements? = nil,
        animation: UITableViewRowAnimation = .none)
    {
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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func performUpdate(_ update: UpdateType) {
    print(update)
}


let insert = TableViewRowsUpdate(changeType: .insert, indexPaths: [IndexPath(row: 0, section: 0)])
let delete = TableViewRowsUpdate(changeType: .delete, indexPaths: [IndexPath(row: 1, section: 0)])

let batch = BatchUpdate(updates: [ insert, delete ])
performUpdate(batch)




























