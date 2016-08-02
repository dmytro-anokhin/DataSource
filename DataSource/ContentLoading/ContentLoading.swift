//
//  ContentLoading.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 30/08/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//


public enum ContentLoadingState {

    /// The initial state
    case initial
    
    /// Loading content
    case loadingContent

    /// Content is loaded successfully
    case contentLoaded
    
    /// No content is available
    case noContent
    
    /// An error occurred while loading content
    case error
}


/// A protocol that defines content loading behavior
public protocol ContentLoading: ContentLoadingObservable {

    /// Current loading state.
    var loadingState: ContentLoadingState { get }
    
    /// Method used to begin loading the content.
    func loadContent()
}


/// A helper class passed to the content loading block
public class ContentLoadingHelper {
    
    /// A closure that performs update on the content loading object.
    public typealias UpdateHandler = () -> Void
    
    typealias CompletionHandler = (state: ContentLoadingState?, error: NSError?, update: UpdateHandler?) -> Void
    
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
            self.doneWithNewState(.noContent, error: nil, update: update)
        }
    }
    
    /// Is this the current loading operation? When -loadContentWithBlock: is called it should inform previous instances of BCLoading that they are no longer the current instance.
    public var current = true
    
    init(completion: CompletionHandler) {
        self.completion = completion
    }
    
    private struct CompletionInfo {
        
        let state: ContentLoadingState
        
        let error: NSError?
        
        let completion: CompletionHandler
        
        let update: UpdateHandler
    }

    private var completion: CompletionHandler?

//    private var lock = NSLock()

    private let queue = DispatchQueue(label: "DataSource.ContentLoadingHelper.serializationQueue")

    private func doneWithNewState(_ state: ContentLoadingState?, error: NSError?, update: UpdateHandler?) {
        
//        lock.lock()
//        
//        defer {
//            lock.unlock()
//        }
//        
        guard let completion = completion else { return }
        self.completion = nil
        
        DispatchQueue.main.async { () -> Void in
            completion(state: state, error: error, update: update)
        }
    }
}
