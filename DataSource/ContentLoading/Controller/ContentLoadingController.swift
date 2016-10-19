//
//  ContentLoadingController.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol ContentLoadingControllerDelegate : class {

    func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController)
    
    func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: @escaping () -> Void)
}


/** The `ContentLoadingController` provides API for loading content. This class manages loading process, encapsulates state transitions and stores an error.
*/
public final class ContentLoadingController {

    // MARK: - Public

    weak var delegate: ContentLoadingControllerDelegate?
    
    public var loadingState: ContentLoadingState {
        if let stateMachine = stateMachine {
            return stateMachine.currentState
        }
        
        return .initial
    }

    public private(set) var loadingError: Error?
    
    /** The `loadContent(_:)` is a principal content loading method.
    
        The method accepts closure with `ContentLoadingCoordinator` argument. The closure encapsulates work required to load content (network interaction, database query, reading from disk, etc.). It is a clients responsibility to implement this work.
        On completion, client must signal the `ContentLoadingCoordinator` that work is done.
        
        - Parameter closure: closure that encapsulates content loading work.
    */
    public func loadContent(_ closure: (_ coordinator: ContentLoadingCoordinator) -> Void) {
    
        assertMainThread()
    
        // Begin loading
        beginLoading()
        
        // Replace current loading coordinator with new one
        currentLoadingCoordinator = ContentLoadingCoordinator { state, error, update in
            guard let state = state else { return } // Ignore

            self.endLoading(state, error: error) {
                update?()
            }
        }
        
        // Execute loading closure
        closure(currentLoadingCoordinator!)
    }
    
    // MARK: - Private
    
    private var stateMachine: ContentLoadingStateMachine?
    
    private var currentLoadingCoordinator: ContentLoadingCoordinator? {
        willSet {
            currentLoadingCoordinator?.current = false
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
    
    private func endLoading(_ state: ContentLoadingState, error: Error?, update: @escaping () -> Void) {
        
        assertMainThread()

        loadingError = error
        updateLoadingState(state)
        
        delegate?.contentLoadingController(self, didFinishLoadingWithUpdate: update)
    }
}
