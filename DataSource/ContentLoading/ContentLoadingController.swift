//
//  ContentLoadingController.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol ContentLoadingControllerDelegate: class {

    func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController)
    
    func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: () -> Void)
}


public class ContentLoadingController {

    // MARK: - Public

    weak var delegate: ContentLoadingControllerDelegate?
    
    public var currentLoadingHelper: ContentLoadingHelper?

    public private(set) var loadingStateMachine: ContentLoadingStateMachine?
    
    public var loadingState: ContentLoadingState {
        if  let loadingStateMachine = loadingStateMachine {
            return loadingStateMachine.currentState
        }
        
        return .initial
    }

    public var loadingError: NSError?
    
    public func loadContent(_ closure: (helper: ContentLoadingHelper) -> Void) {
    
        assertMainThread()
    
        // Begin loading
        beginLoading()
        
        let loadingHelper = ContentLoadingHelper { state, error, update in
            guard let state = state else { return } // Ignore

            self.endLoading(state, error: error) {
                update?()
            }
        }
        
        // Tell previous loading helper it's no longer current and remember this loading helper
        currentLoadingHelper?.current = false
        currentLoadingHelper = loadingHelper
        
        // Call the provided closure to actually do the load
        closure(helper: loadingHelper)
    }
    
    // MARK: - Private
    
    private func updateLoadingState(_ state: ContentLoadingState) {
        if nil == loadingStateMachine {
            loadingStateMachine = ContentLoadingStateMachine()
        }
        
        guard let loadingStateMachine = loadingStateMachine,
            loadingStateMachine.currentState != state
        else {
            return
        }
        
        loadingStateMachine.currentState = state
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
