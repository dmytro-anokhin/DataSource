//
//  Update.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 04/04/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The Update class encapsulates request to update view from data source
// TODO: Why class, only for inheritance? maybe protocol, struct or enum? at least mark as final
public class Update {
    
    public enum UpdateType {
        case insert
        case delete
        case reload
        case move
    }
    
    public func perform(_ view: UIView?) {
    }

    // MARK: - Factory functions
    
    public class func batchUpdate(_ updates: [Update]) -> Update {
        return BatchUpdate(updates: updates)
    }
    
    public class func arbitraryUpdate(_ closure: () -> Void) -> Update {
        return ArbitraryUpdate(closure: closure)
    }
}


public class ArbitraryUpdate: Update {
    
    public let closure: () -> Void
    
    public init(closure: () -> Void) {
        self.closure = closure
    }
    
    public final override func perform(_ view: UIView?) {
        closure()
    }
}


public protocol AnimatedUpdate {
    var animated: Bool { get }
}


/// The BatchUpdate class aggregates multiple requests to update view from data source
public class BatchUpdate: Update, AnimatedUpdate {

    public init(updates: [Update] = []) {
        self.updates = updates
        
        for update in updates {
            if let animatedUpdate = update as? AnimatedUpdate, animatedUpdate.animated {
                animated = true
                break
            }
        }
    }

    public private(set) var updates: [Update] = []

    public func enqueueUpdate(_ update: Update) {
        updates.append(update)
        
        if let animatedUpdate = update as? AnimatedUpdate, animatedUpdate.animated {
            animated = true
        }
    }

    /// If at least one of the updates is animated - batch considered to be animated
    public private(set) var animated: Bool = false

    public override func perform(_ view: UIView?) {
        for update in updates {
            update.perform(view)
        }
    }
}
