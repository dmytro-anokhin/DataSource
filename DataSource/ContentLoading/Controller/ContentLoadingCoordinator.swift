//
//  ContentLoadingCoordinator.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 08/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The `ContentLoadingCoordinator` receives actions from content loading process and signals necessary updates on the `ContentLoadingController`.
public class ContentLoadingCoordinator {
    
    /// A closure that performs update on the content loading object.
    public typealias UpdateHandler = () -> Void
    
    typealias CompletionHandler = (state: ContentLoadingState?, error: NSError?, update: UpdateHandler?) -> Void
    
    init(completion: CompletionHandler) {
        self.completion = completion
    }
    
    // MARK: - Public
    
    /// Signals that this result should be ignored. Sends a nil value for the state to the completion handler.
    public func ignore() {
        queue.sync {
            self.doneWithNewState(nil, error: nil, update: nil)
        }
    }
    
    /// Signals that loading is complete with no errors. This triggers a transition to the Loaded state.
    public func done() {
        queue.sync {
            self.doneWithNewState(.contentLoaded, error: nil, update: nil)
        }
    }
    
    /// Signals that loading failed with an error. This triggers a transition to the Error state.
    public func doneWithError(_ error: NSError) {
        queue.sync {
            self.doneWithNewState(.error, error: error, update: nil)
        }
    }

    /// Signals that loading is complete, transitions into the Loaded state and then runs the update block.
    public func updateWithContent(_ update: UpdateHandler? = nil) {
        queue.sync {
            self.doneWithNewState(.contentLoaded, error: nil, update: update)
        }
    }
    
    /// Signals that loading completed with no content, transitions to the No Content state and then runs the update block.
    public func updateWithNoContent(_ update: UpdateHandler? = nil) {
        queue.sync {
            self.doneWithNewState(.contentLoaded, error: nil, update: update)
        }
    }
    
    /// Is this the current loading operation? When loadContent(_:) is called it should inform previous instances of ContentLoadingCoordinator that they are no longer the current instance.
    public var current = true
    
    // MARK: - Private
    
    private var completion: CompletionHandler?

    private let queue = DispatchQueue(label: "DataSource.ContentLoadingCoordinator.serializationQueue")

    private func doneWithNewState(_ state: ContentLoadingState?, error: NSError?, update: UpdateHandler?) {

        guard let completion = completion else { return }
        self.completion = nil
        
        DispatchQueue.main.async { () -> Void in
            completion(state: state, error: error, update: update)
        }
    }
}
