//
//  ContentLoadingController.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol ContentLoadingControllerDelegate : class {

    func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController)
    
    func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: () -> Void)
}


public class ContentLoadingController {

    // MARK: - Public

    weak var delegate: ContentLoadingControllerDelegate?
    
    public var loadingState: ContentLoadingState {
        if let stateMachine = stateMachine {
            return stateMachine.currentState
        }
        
        return .initial
    }

    public var loadingError: NSError?
    
    public func loadContent(_ closure: (helper: ContentLoadingHelper) -> Void) {
    
        assertMainThread()
    
        // Begin loading
        beginLoading()
        
        // Replace current loading helper with new one
        currentLoadingHelper = ContentLoadingHelper { state, error, update in
            guard let state = state else { return } // Ignore

            self.endLoading(state, error: error) {
                update?()
            }
        }
        
        // Execute loading closure
        closure(helper: currentLoadingHelper!)
    }
    
    // MARK: - Private
    
    private var stateMachine: ContentLoadingStateMachine?
    
    private var currentLoadingHelper: ContentLoadingHelper? {
        willSet {
            currentLoadingHelper?.current = false
        }
    }

    private func updateLoadingState(_ state: ContentLoadingState) {
        if nil == stateMachine {
            stateMachine = ContentLoadingStateMachine()
        }
        
        stateMachine?.currentState = state
    }
    
    private func beginLoading() {
        updateLoadingState(.loadingContent)
        delegate?.contentLoadingControllerWillBeginLoading(self)
    }
    
    private func endLoading(_ state: ContentLoadingState, error: NSError?, update: () -> Void) {
        
        assertMainThread()

        loadingError = error
        updateLoadingState(state)
        
        delegate?.contentLoadingController(self, didFinishLoadingWithUpdate: update)
    }
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
            self.doneWithNewState(.contentLoaded, error: nil, update: update)
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
