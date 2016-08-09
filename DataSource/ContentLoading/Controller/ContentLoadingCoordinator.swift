//
//  ContentLoadingCoordinator.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 08/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/** The `ContentLoadingCoordinator` receives signals from content loading process and performs necessary state transitions on the `ContentLoadingController`.

    The `ContentLoadingCoordinator` can receive signals from any thread. State transition is performed on the main queue.
*/
public class ContentLoadingCoordinator {
    
    // MARK: - Public
    
    /// A closure that performs update on the content loading object.
    public typealias Update = () -> Void
    
    /// Signals that this result should be ignored.
    public func ignore() {
        done(withState: nil, error: nil, update: nil)
    }
    
    /// Signals that loading failed with an error. This triggers a transition to the `.error` state.
    public func done(withError error: NSError) {
        done(withState: .error, error: error, update: nil)
    }

    /// Signals that loading is complete, transitions into the `.loaded` state and then runs the update block.
    public func done(withUpdate update: Update? = nil) {
        done(withState: .contentLoaded, error: nil, update: update)
    }
    
    private var _current = true
    
    /// Is this the current loading operation? When loading starts, previous coordinators are informed that they are no longer the current. Such coordinators must be ignored upon operation completion.
    public internal(set) var current: Bool {
        get {
            var current = true
        
            queue.sync(flags: .barrier) {
                current = self._current
            }
            
            return current
        }
        
        set {
            queue.async(flags: .barrier) {
                self._current = newValue
            }
        }
    }
    
    // MARK: - Internal
    
    typealias CompletionHandler = (state: ContentLoadingState?, error: NSError?, update: Update?) -> Void
    
    init(completion: CompletionHandler) {
        self.completion = completion
    }
    
    // MARK: - Private
    
    private var completion: CompletionHandler?

    /// Synchronization queue. Coordinator may receive signals from multiple threads.
    private let queue = DispatchQueue(label: "DataSource.ContentLoadingCoordinator.synchronizationQueue",
        attributes: .concurrent)

    private func done(withState state: ContentLoadingState?, error: NSError?, update: Update?) {
        queue.async(flags: .barrier) {
            guard let completion = self.completion else { return }
            self.completion = nil
            
            DispatchQueue.main.async { () -> Void in
                completion(state: state, error: error, update: update)
            }
        }
    }
}
